/**
 * Stack Sequence Horizontally (Sum Widths)
 * 
 * Changes the active sequence's dimensions to accommodate stacking selected clips horizontally.
 * - Width: Sum of all selected clips' widths
 * - Height: Maximum height among all selected clips
 * 
 * Example: Two images (1500×1000, 2000×1500) → Sequence becomes 3500×1500
 * 
 * Features:
 * - Works with currently selected clips in the timeline
 * - Sums widths for horizontal stacking
 * - Uses maximum height to fit all clips
 */

// Constants
var TICKS_PER_SECOND = 254016000000;

/**
 * Validates that a sequence is available for processing
 * @returns {Object|null} The active sequence or null if invalid
 */
function getValidSequence() {
    if (!app.project || !app.project.activeSequence) {
        alert('Error: No active sequence found. Please open a sequence first.');
        return null;
    }
    return app.project.activeSequence;
}

/**
 * Attempts to parse dimensions from regex matches
 * @param {Array|null} widthMatch - Width regex match result
 * @param {Array|null} heightMatch - Height regex match result
 * @returns {Object|null} Object with width and height, or null if invalid
 */
function parseDimensionMatches(widthMatch, heightMatch) {
    if (!widthMatch || !heightMatch) {
        return null;
    }
    return {
        width: parseInt(widthMatch[1], 10),
        height: parseInt(heightMatch[1], 10)
    };
}

/**
 * Tries to extract dimensions using a pair of regex patterns
 * @param {string} source - Source string to search
 * @param {string} widthPattern - Regex pattern for width
 * @param {string} heightPattern - Regex pattern for height
 * @returns {Object|null} Dimensions or null
 */
function tryDimensionPatterns(source, widthPattern, heightPattern) {
    var widthMatch = source.match(new RegExp(widthPattern));
    var heightMatch = source.match(new RegExp(heightPattern));
    return parseDimensionMatches(widthMatch, heightMatch);
}

/**
 * Extracts dimensions from project metadata
 * @param {string} metadata - Project metadata XML string
 * @returns {Object|null} Dimensions or null
 */
function extractFromProjectMetadata(metadata) {
    var patterns = [
        ['VideoFrameSizeH[^>]*>(\\d+)<', 'VideoFrameSizeV[^>]*>(\\d+)<'],
        ['ImageWidth[^>]*>(\\d+)<', 'ImageHeight[^>]*>(\\d+)<']
    ];
    
    for (var i = 0; i < patterns.length; i++) {
        var result = tryDimensionPatterns(metadata, patterns[i][0], patterns[i][1]);
        if (result) {
            return result;
        }
    }
    
    // Try resolution pattern (e.g., "1920x1080")
    var resMatch = metadata.match(/(\d+)\s*[xX×]\s*(\d+)/);
    if (resMatch) {
        return {
            width: parseInt(resMatch[1], 10),
            height: parseInt(resMatch[2], 10)
        };
    }
    
    return null;
}

/**
 * Extracts dimensions from XMP metadata
 * @param {string} xmpBlob - XMP metadata string
 * @returns {Object|null} Dimensions or null
 */
function extractFromXmpMetadata(xmpBlob) {
    var patterns = [
        ['stDim:w[^>]*>(\\d+)<', 'stDim:h[^>]*>(\\d+)<'],
        ['exif:PixelXDimension[^>]*>(\\d+)<', 'exif:PixelYDimension[^>]*>(\\d+)<'],
        ['tiff:ImageWidth[^>]*>(\\d+)<', 'tiff:ImageLength[^>]*>(\\d+)<']
    ];
    
    for (var i = 0; i < patterns.length; i++) {
        var result = tryDimensionPatterns(xmpBlob, patterns[i][0], patterns[i][1]);
        if (result) {
            return result;
        }
    }
    
    return null;
}

/**
 * Extracts video dimensions from project item
 * @param {Object} projectItem - The project item to get dimensions from
 * @returns {Object|null} Object with width and height, or null if not found
 */
function getClipDimensions(projectItem) {
    if (!projectItem) {
        return null;
    }
    
    try {
        // Try project metadata first
        var metadata = projectItem.getProjectMetadata();
        if (metadata) {
            var result = extractFromProjectMetadata(metadata);
            if (result) {
                return result;
            }
        }
        
        // Fallback to XMP metadata
        var xmpBlob = projectItem.getXMPMetadata();
        if (xmpBlob) {
            return extractFromXmpMetadata(xmpBlob);
        }
        
        return null;
    } catch (e) {
        return null;
    }
}

/**
 * Collects dimensions from all selected video clips
 * @param {Object} sequence - The active sequence
 * @returns {Array} Array of objects with width and height
 */
function collectSelectedClipDimensions(sequence) {
    var clips = [];
    var videoTracks = sequence.videoTracks;
    var processedItems = {};
    
    for (var trackIdx = 0; trackIdx < videoTracks.numTracks; trackIdx++) {
        var track = videoTracks[trackIdx];
        
        for (var clipIdx = 0; clipIdx < track.clips.numItems; clipIdx++) {
            var clip = track.clips[clipIdx];
            
            if (!clip.isSelected()) {
                continue;
            }
            
            var projectItem = clip.projectItem;
            if (!projectItem) {
                continue;
            }
            
            // Avoid processing same source multiple times
            var itemId = projectItem.nodeId || (projectItem.name + '_' + clipIdx);
            if (processedItems[itemId]) {
                continue;
            }
            processedItems[itemId] = true;
            
            var dimensions = getClipDimensions(projectItem);
            if (!dimensions) {
                continue;
            }
            
            clips.push({
                name: projectItem.name,
                width: dimensions.width,
                height: dimensions.height
            });
        }
    }
    
    return clips;
}

/**
 * Calculates dimensions for horizontal stacking
 * @param {Array} clips - Array of clip dimension objects
 * @returns {Object} Object with width (sum) and height (max)
 */
function calculateHorizontalStackDimensions(clips) {
    var totalWidth = 0;
    var maxHeight = 0;
    
    for (var i = 0; i < clips.length; i++) {
        totalWidth += clips[i].width;
        if (clips[i].height > maxHeight) {
            maxHeight = clips[i].height;
        }
    }
    
    return {
        width: totalWidth,
        height: maxHeight
    };
}

/**
 * Changes sequence dimensions to specified width and height
 * @param {Object} sequence - The sequence to modify
 * @param {number} width - New width
 * @param {number} height - New height
 * @returns {boolean} True if successful
 */
function setSequenceDimensions(sequence, width, height) {
    try {
        var settings = sequence.getSettings();
        if (!settings) {
            return false;
        }
        
        settings.videoFrameWidth = width;
        settings.videoFrameHeight = height;
        
        sequence.setSettings(settings);
        return true;
    } catch (e) {
        return false;
    }
}

/**
 * Main execution function
 */
function stackSequenceHorizontally() {
    var sequence = getValidSequence();
    if (!sequence) {
        return;
    }
    
    var clipDimensions = collectSelectedClipDimensions(sequence);
    
    if (clipDimensions.length === 0) {
        alert('Error: No selected clips with valid dimensions found.\nPlease select video clips on the timeline.');
        return;
    }
    
    var stackedDimensions = calculateHorizontalStackDimensions(clipDimensions);
    
    if (stackedDimensions.width === 0 || stackedDimensions.height === 0) {
        alert('Error: Invalid calculated dimensions.');
        return;
    }
    
    var success = setSequenceDimensions(
        sequence,
        stackedDimensions.width,
        stackedDimensions.height
    );
    
    if (!success) {
        alert('Error: Failed to update sequence dimensions.');
    }
}

// Execute
stackSequenceHorizontally();
