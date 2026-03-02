/**
 * Stack Selected Clips on Separate Tracks
 * 
 * Takes all SELECTED clips in the timeline and places them on separate video tracks,
 * starting from the LOWEST track with selected clips.
 * 
 * Features:
 * - Only processes SELECTED clips
 * - Finds the lowest track containing selected clips
 * - Stacks clips vertically starting from that track
 * - Aligns all clips to the LEFT-MOST selected clip's in-point
 * - Creates additional video tracks automatically if needed
 * - Preserves original clip trim/duration (source in/out points)
 * - Video-only insertion (audio from source clips is NOT re-added)
 * - Handles clips of different durations correctly
 * - Uses correct tick conversion (254016000000 ticks per second)
 */

// ─── Constants ───────────────────────────────────────────────────────────────
var TICKS_PER_SECOND = 254016000000;
var MEDIA_TYPE_VIDEO = 4;
var TIME_TOLERANCE_SECONDS = 2.0;
var TRIM_TOLERANCE_SECONDS = 0.01;

// ─── Utility ─────────────────────────────────────────────────────────────────

/**
 * Creates a Time object set to the given seconds value.
 * Premiere's ExtendScript API requires assignment of a Time object
 * rather than setting .seconds directly on existing Time properties.
 * @param {number} seconds - Time value in seconds
 * @returns {Object} A Time object
 */
function createTime(seconds) {
    var t = new Time();
    t.seconds = seconds;
    return t;
}

/** Converts seconds to a ticks string for Premiere API calls. */
function secondsToTicks(seconds) {
    return Math.round(seconds * TICKS_PER_SECOND).toString();
}

// ─── Sequence validation ─────────────────────────────────────────────────────

/**
 * Validates that a sequence is available for processing.
 * @returns {Object|null} The active sequence or null if invalid
 */
function getValidSequence() {
    if (!app.project || !app.project.activeSequence) {
        alert('Error: No active sequence found. Please open a sequence first.');
        return null;
    }
    
    var sequence = app.project.activeSequence;
    if (sequence.videoTracks.numTracks === 0) {
        alert('Error: No video tracks in sequence.');
        return null;
    }
    
    return sequence;
}

// ─── Clip collection ─────────────────────────────────────────────────────────

/** Builds a clip metadata snapshot from a single selected TrackItem. */
function buildClipSnapshot(clip, trackIdx) {
    var startSec = clip.start.seconds;
    var endSec = clip.end.seconds;
    
    return {
        clip: clip,
        trackIndex: trackIdx,
        startTime: startSec,
        endTime: endSec,
        inPointSeconds: clip.inPoint.seconds,
        outPointSeconds: clip.outPoint.seconds,
        durationSeconds: endSec - startSec,
        projectItem: clip.projectItem
    };
}

/**
 * Collects all selected clips from video tracks with full metadata
 * needed to preserve trimming and duration when re-inserting.
 * @param {Object} videoTracks - The video tracks collection
 * @returns {Object} Contains clips array, lowestTrackIndex, and leftmostStartTime
 */
function collectSelectedClips(videoTracks) {
    var result = {
        clips: [],
        lowestTrackIndex: -1,
        leftmostStartTime: Infinity
    };
    
    for (var trackIdx = 0; trackIdx < videoTracks.numTracks; trackIdx++) {
        var track = videoTracks[trackIdx];
        
        for (var clipIdx = 0; clipIdx < track.clips.numItems; clipIdx++) {
            var clip = track.clips[clipIdx];
            
            if (!clip.isSelected()) {
                continue;
            }
            
            var snapshot = buildClipSnapshot(clip, trackIdx);
            result.clips.push(snapshot);
            
            if (result.lowestTrackIndex === -1 || trackIdx < result.lowestTrackIndex) {
                result.lowestTrackIndex = trackIdx;
            }
            
            if (snapshot.startTime < result.leftmostStartTime) {
                result.leftmostStartTime = snapshot.startTime;
            }
        }
    }
    
    return result;
}

/**
 * Validates that clips were found.
 * @param {Object} clipData - The collected clip data
 * @returns {boolean} True if valid, false otherwise
 */
function validateClipSelection(clipData) {
    if (clipData.clips.length === 0) {
        alert('Error: No selected clips found. Please select clips on the timeline first.');
        return false;
    }
    
    if (clipData.lowestTrackIndex === -1) {
        alert('Error: Could not determine lowest track with selected clips.');
        return false;
    }
    
    return true;
}

// ─── Track management ────────────────────────────────────────────────────────

/**
 * Ensures the sequence has at least the required number of video tracks.
 * Uses QE DOM to add tracks when the current count is insufficient.
 * @param {Object} sequence - The active sequence
 * @param {number} requiredCount - Minimum number of video tracks needed
 */
function ensureVideoTrackCount(sequence, requiredCount) {
    var currentCount = sequence.videoTracks.numTracks;
    if (requiredCount <= currentCount) {
        return;
    }
    
    var tracksToAdd = requiredCount - currentCount;
    
    try {
        app.enableQE();
        qe.project.getActiveSequence().addTracks(tracksToAdd, 0, 0);
    } catch (e) {
        alert('Warning: Could not auto-create ' + tracksToAdd + ' video track(s).\n'
            + 'Please manually add them and try again.\n\nError: ' + e.message);
    }
}

// ─── Clip removal ────────────────────────────────────────────────────────────

/**
 * Removes all selected clips from timeline using non-ripple delete.
 * Iterates in reverse to avoid index-shifting issues on the same track.
 */
function removeClipsFromTimeline(clips) {
    for (var i = clips.length - 1; i >= 0; i--) {
        clips[i].clip.remove(false, false);
    }
}

// ─── Audio track locking ─────────────────────────────────────────────────────

/**
 * Captures the current lock state of every audio track.
 * @returns {Array<boolean>} Lock state per track index
 */
function captureAudioLockStates(audioTracks) {
    var states = [];
    for (var t = 0; t < audioTracks.numTracks; t++) {
        try { states[t] = audioTracks[t].isLocked(); }
        catch (e) { states[t] = false; }
    }
    return states;
}

/**
 * Sets every audio track to locked or unlocked.
 * @param {Object} audioTracks - The audio tracks collection
 * @param {boolean} lock - true to lock, false to unlock
 */
function setAllAudioTracksLocked(audioTracks, lock) {
    var lockVal = lock ? 1 : 0;
    for (var t = 0; t < audioTracks.numTracks; t++) {
        try { audioTracks[t].setLocked(lockVal); }
        catch (e) { /* skip uncooperative track */ }
    }
}

/**
 * Restores audio track lock states to previously captured values.
 */
function restoreAudioTrackLockStates(audioTracks, savedStates) {
    for (var t = 0; t < audioTracks.numTracks; t++) {
        try { audioTracks[t].setLocked(savedStates[t] ? 1 : 0); }
        catch (e) { /* skip */ }
    }
}

// ─── Audio cleanup ───────────────────────────────────────────────────────────

/** Records clip counts on all audio tracks for later diff. */
function getAudioClipCounts(audioTracks) {
    var counts = [];
    for (var t = 0; t < audioTracks.numTracks; t++) {
        counts[t] = audioTracks[t].clips.numItems;
    }
    return counts;
}

/** Removes newly-added audio clips near insertTimeSeconds on one track. */
function removeNewClipsOnTrack(track, expectedNew, insertTimeSeconds) {
    var removed = 0;
    for (var c = track.clips.numItems - 1; c >= 0 && removed < expectedNew; c--) {
        if (Math.abs(track.clips[c].start.seconds - insertTimeSeconds) < TIME_TOLERANCE_SECONDS) {
            track.clips[c].remove(false, false);
            removed++;
        }
    }
}

/**
 * Removes any audio clips that were auto-added during video insertion.
 * Compares current clip counts against a pre-insertion snapshot.
 */
function removeAutoAddedAudioClips(audioTracks, preInsertCounts, insertTimeSeconds) {
    for (var t = 0; t < audioTracks.numTracks; t++) {
        var newClipCount = audioTracks[t].clips.numItems - (preInsertCounts[t] || 0);
        if (newClipCount > 0) {
            removeNewClipsOnTrack(audioTracks[t], newClipCount, insertTimeSeconds);
        }
    }
}

/**
 * Removes any empty audio tracks that were auto-created during insertion.
 * Premiere may add a junk audio track when inserting A/V clips with locked audio.
 */
function removeJunkAudioTracks(preInsertAudioTrackCount) {
    try {
        app.enableQE();
        var qeSeq = qe.project.getActiveSequence();
        var currentCount = app.project.activeSequence.audioTracks.numTracks;
        
        for (var t = currentCount - 1; t >= preInsertAudioTrackCount; t--) {
            qeSeq.removeAudioTrack(t);
        }
    } catch (e) {
        // QE cleanup optional — auto-added audio clips already handled above
    }
}

// ─── ProjectItem in/out point management ─────────────────────────────────────

/** Safely reads a ProjectItem's current in-point, or returns null. */
function getSavedInPoint(projectItem) {
    try { return projectItem.getInPoint(); }
    catch (e) { return null; }
}

/** Safely reads a ProjectItem's current out-point, or returns null. */
function getSavedOutPoint(projectItem) {
    try { return projectItem.getOutPoint(); }
    catch (e) { return null; }
}

/**
 * Sets a ProjectItem's source in/out to match a clip's original trim.
 * insertClip respects these values when they are set before insertion.
 */
function applySourceTrim(projectItem, inSec, outSec) {
    try {
        projectItem.setInPoint(inSec, MEDIA_TYPE_VIDEO);
        projectItem.setOutPoint(outSec, MEDIA_TYPE_VIDEO);
    } catch (e) {
        // Fallback: insertClip will use full source range
    }
}

/** Restores a ProjectItem's in/out to their saved values, clearing if none. */
function restoreSourceTrim(projectItem, savedIn, savedOut) {
    try {
        if (savedIn !== null) { projectItem.setInPoint(savedIn.seconds, MEDIA_TYPE_VIDEO); }
        else { projectItem.clearInPoint(); }
    } catch (e) { /* skip */ }
    
    try {
        if (savedOut !== null) { projectItem.setOutPoint(savedOut.seconds, MEDIA_TYPE_VIDEO); }
        else { projectItem.clearOutPoint(); }
    } catch (e) { /* skip */ }
}

// ─── Post-insertion trim verification ────────────────────────────────────────

/**
 * Finds a clip on a track whose start time is nearest to the given time.
 * @returns {Object|null} The matching clip or null
 */
function findClipNearTime(track, timeSeconds) {
    var bestClip = null;
    var bestDiff = Infinity;
    
    for (var i = 0; i < track.clips.numItems; i++) {
        var diff = Math.abs(track.clips[i].start.seconds - timeSeconds);
        if (diff < bestDiff && diff < TIME_TOLERANCE_SECONDS) {
            bestDiff = diff;
            bestClip = track.clips[i];
        }
    }
    
    return bestClip;
}

/** Sets a Time property on a clip if it differs from expected by more than tolerance. */
function correctTimeProperty(clip, propertyName, expectedSeconds) {
    if (Math.abs(clip[propertyName].seconds - expectedSeconds) > TRIM_TOLERANCE_SECONDS) {
        try { clip[propertyName] = createTime(expectedSeconds); }
        catch (e) { /* property may be read-only in some contexts */ }
    }
}

/**
 * Verifies and corrects the newly-inserted clip's trim to match the original.
 * Handles cases where ProjectItem in/out setting didn't take effect.
 */
function verifyClipTrim(track, insertTimeSeconds, clipData) {
    var newClip = findClipNearTime(track, insertTimeSeconds);
    if (!newClip) {
        return;
    }
    
    correctTimeProperty(newClip, 'end', insertTimeSeconds + clipData.durationSeconds);
    correctTimeProperty(newClip, 'inPoint', clipData.inPointSeconds);
    correctTimeProperty(newClip, 'outPoint', clipData.outPointSeconds);
}

// ─── Single-clip insertion ───────────────────────────────────────────────────

/**
 * Inserts one clip onto a target track, preserving original trim.
 * Manages the ProjectItem's in/out points bracketed around insertion
 * and verifies the result afterward.
 */
function insertSingleClip(clipData, targetTrack, insertTimeTicks, insertTimeSeconds) {
    if (!targetTrack || !clipData.projectItem) {
        return;
    }
    
    var savedIn = getSavedInPoint(clipData.projectItem);
    var savedOut = getSavedOutPoint(clipData.projectItem);
    
    applySourceTrim(clipData.projectItem, clipData.inPointSeconds, clipData.outPointSeconds);
    targetTrack.insertClip(clipData.projectItem, insertTimeTicks);
    restoreSourceTrim(clipData.projectItem, savedIn, savedOut);
    
    verifyClipTrim(targetTrack, insertTimeSeconds, clipData);
}

// ─── Orchestration ───────────────────────────────────────────────────────────

/**
 * Main execution function.
 * 
 * Strategy:
 * 1. Collect all selected clips with full metadata (in/out, duration)
 * 2. Ensure enough video tracks exist (add via QE DOM if needed)
 * 3. Remove original clips from timeline
 * 4. Lock all audio tracks to prevent auto-adding audio from A/V sources
 * 5. Insert each clip on its own video track, preserving trim
 * 6. Restore audio track lock states 
 * 7. Clean up any auto-added audio clips/tracks as a safety net
 */
function stackClipsOnSeparateTracks() {
    var sequence = getValidSequence();
    if (!sequence) {
        return;
    }
    
    var clipData = collectSelectedClips(sequence.videoTracks);
    if (!validateClipSelection(clipData)) {
        return;
    }
    
    var clips = clipData.clips;
    var baseTrackIndex = clipData.lowestTrackIndex;
    var requiredTrackCount = baseTrackIndex + clips.length;
    var insertTimeSeconds = clipData.leftmostStartTime;
    var insertTimeTicks = secondsToTicks(insertTimeSeconds);
    
    // Ensure enough video tracks exist
    ensureVideoTrackCount(sequence, requiredTrackCount);
    var videoTracks = sequence.videoTracks;
    var audioTracks = sequence.audioTracks;
    
    if (videoTracks.numTracks < requiredTrackCount) {
        alert('Error: Not enough video tracks. Need ' + requiredTrackCount
            + ' but only have ' + videoTracks.numTracks
            + '.\nPlease add more video tracks manually and try again.');
        return;
    }
    
    // Remove originals and prepare audio isolation
    removeClipsFromTimeline(clips);
    var preInsertAudioTrackCount = audioTracks.numTracks;
    var audioClipCountsBefore = getAudioClipCounts(audioTracks);
    var savedAudioLockStates = captureAudioLockStates(audioTracks);
    setAllAudioTracksLocked(audioTracks, true);
    
    // Insert each clip on a separate video track
    for (var i = 0; i < clips.length; i++) {
        insertSingleClip(clips[i], videoTracks[baseTrackIndex + i], insertTimeTicks, insertTimeSeconds);
    }
    
    // Restore audio state and clean up any leaked audio
    restoreAudioTrackLockStates(audioTracks, savedAudioLockStates);
    removeAutoAddedAudioClips(audioTracks, audioClipCountsBefore, insertTimeSeconds);
    removeJunkAudioTracks(preInsertAudioTrackCount);
}

// Execute
stackClipsOnSeparateTracks();