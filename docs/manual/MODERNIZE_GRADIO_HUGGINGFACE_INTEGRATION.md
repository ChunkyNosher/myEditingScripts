# NeMo Gradio UI Modernization: HuggingFace Space Integration

**Repository:** myEditingScripts | **Date:** 2025-12-24 | **Scope:** Modernize transcribe_ui.py to match HuggingFace Space's robust patterns while preserving multi-model, local loading, and video support features

---

## Problem Summary

Your current `transcribe_ui.py` implements the core transcription functionality correctly, but deviates from proven production-grade patterns used in the **working HuggingFace Spaces implementation**. The HuggingFace Space has been running reliably in production for months with zero deadlock issues.

**Key Gaps Between Your Code and HuggingFace (Best Practices):**

1. **Overly Complex Audio Preprocessing** — Handles audio detection inline. HuggingFace explicitly normalizes all audio to 16kHz mono upfront.
2. **Missing Explicit Format Validation** — HuggingFace validates audio format, duration, and sample rate before transcription.
3. **No Output Validation Before Accessing** — HuggingFace performs 8-point validation on transcribe() results before accessing `.text` attribute.
4. **Implicit Device Management** — HuggingFace explicitly moves model to CUDA/CPU and cleans up between runs.
5. **Brittle Timestamp Access** — Your code assumes structure exists. HuggingFace uses defensive checks and graceful fallbacks.
6. **Weak Batch Processing Error Handling** — One corrupted hypothesis breaks the entire batch.
7. **No Fallback Timestamp Strategies** — HuggingFace uses segment-level timestamps when word-level unavailable.

---

## Specific Changes Required

### Change 1: Add Audio Format Validation Function

**What Needs Adding:**

Create a new function `validate_and_normalize_audio()` that:

1. Accepts audio file path
2. Loads audio with librosa (handles WAV, MP3, FLAC, M4A via FFmpeg)
3. Checks if audio duration is reasonable (100ms - 24 hours)
4. Validates audio is not silent or corrupted (RMS energy check)
5. Explicitly resamples to 16kHz if different
6. Converts to mono if stereo
7. Returns tuple: (success: bool, audio_data: ndarray, sample_rate: int, error_msg: str)

**Why This Works:**
- Ensures consistent preprocessing regardless of input format
- Catches invalid audio upfront (duration=0, empty files)
- Prevents silent failures from format mismatches
- Model expects 16kHz mono; preprocessing guarantees this

---

### Change 2: Add Pre-Transcription Output Validation Function

**What Needs Adding:**

Create a new function `validate_transcription_result()` that:

1. Accepts result from `model.transcribe()` and hypothesis index
2. Checks result is not None and not empty list
3. Validates result is list type
4. For the given index:
   - Check hypothesis object exists
   - Check `.text` attribute exists (hasattr)
   - Check `.text` is string type
   - Check `.text` length > 0 (non-empty)
5. Returns tuple: (success: bool, text: str, error_msg: str)

**Why This Works:**
- Prevents crashes from accessing `.text` on malformed hypotheses
- Catches NeMo edge cases where transcribe() returns empty or None
- Allows graceful error reporting vs AttributeError

---

### Change 3: Add Explicit Device Management to Model Loading

**What Needs Changing in `load_model()`:**

Before loading a new model:

1. Check if a model is already in `models_cache` from a DIFFERENT model_key
2. If yes: unload the old model by:
   - Moving to CPU: `old_model = old_model.to("cpu")`
   - Deleting reference: `del old_model`
   - Emptying CUDA cache: `torch.cuda.empty_cache()`
   - Force garbage collection: `gc.collect()`
3. After loading new model:
   - Explicitly move to CUDA if available: `model = model.to("cuda")`

**Why This Works:**
- Prevents multiple models in VRAM simultaneously
- Allows seamless model switching without OOM
- Frees VRAM immediately when switching models

---

### Change 4: Add Defensive Timestamp Extraction Function

**What Needs Adding:**

Create a new function `extract_timestamps()` that:

1. Accepts hypothesis object and `include_timestamps` flag
2. If not including timestamps, return empty list + 'none'
3. Try word-level timestamps:
   - Check if hypothesis has `.timestamp` attribute
   - Check if `.timestamp` is not None
   - Check if 'word' key exists in timestamp dict
   - Check if timestamp['word'] is non-empty list
   - Return word-level timestamps + 'word'
4. Fallback to segment-level:
   - Same checks for 'segment' key
   - Return segment-level timestamps + 'segment'
5. If all fail, return empty list + 'none'

**Why This Works:**
- Graceful degradation: word → segment → none
- No crashes from KeyError or AttributeError
- Users see timestamps when available

---

### Change 5: Add Stage-Specific Error Messages

**What Needs Adding:**

Create an error message dictionary with stage-specific, actionable messages for:
- Audio load failures
- Audio format unsupported
- Invalid audio duration
- Audio silent/quiet
- Output validation failures
- Batch partial failures

**Why This Works:**
- Users know exact stage that failed
- Actionable next steps provided
- Reduces support burden

---

### Change 6: Refactor `transcribe_audio()` for Per-File Batch Validation

**What Needs Changing:**

Instead of bulk transcription of all files at once:

1. Loop through each file individually
2. Wrap each file in try/except
3. Validate each result before accessing
4. Collect per-file results and errors separately
5. Return status with per-file information

**Why This Works:**
- One bad file doesn't crash entire batch
- Users see which files succeeded/failed
- Allows selective re-processing

---

### Change 7: Update Status Messages to Show Timestamp Level

**What Needs Adding:**

Update status messages to indicate:
- "✅ Word-level timestamps available" (if word-level found)
- "⚠️ Segment-level timestamps (word-level unavailable)" (if segment fallback used)
- "ℹ️ Timestamps not available for this model" (if none available)

**Why This Works:**
- Transparent about capabilities
- Users know why they got certain results
- Prevents confusion

---

<acceptance_criteria>
- [ ] Audio validation function added: `validate_and_normalize_audio()`
- [ ] Output validation function added: `validate_transcription_result()`
- [ ] Device management improved: Explicit to(cuda)/to(cpu) with cleanup
- [ ] Timestamp extraction function added: `extract_timestamps()`
- [ ] Error message dictionary created with 6 stage-specific error types
- [ ] Batch processing refactored: Per-file validation with error collection
- [ ] Status messages updated: Show timestamp level used
- [ ] Single file transcription works with all validations
- [ ] Batch transcription handles partial failures (per-file error collection)
- [ ] Multi-model switching works with explicit device cleanup (no OOM)
- [ ] Video files still auto-extract audio before validation
- [ ] All existing error handling preserved
- [ ] Local model loading still preferred over HuggingFace
- [ ] Manual test: Single file → clear status, validation passes, transcription shows
- [ ] Manual test: Batch (5 files, 1 invalid) → 4 succeed, 1 shows per-file error
- [ ] Manual test: Model switch → Old model unloaded, new model loaded, VRAM freed
</acceptance_criteria>

---

## Implementation Notes

**Priority:** High (improves reliability, matches proven patterns)  
**Complexity:** Medium (5 new functions, 1 major refactor)  
**Risk Level:** Low (backward compatible, no breaking changes)  
**Testing:** Manual transcription (single + batch) with valid/invalid files  
**Dependencies:** librosa (already imported), torch (already imported)

**Backward Compatibility:** All changes are additive and internal. The transcribe_ui.py API and Gradio interface remain unchanged.

---

**Status:** Ready for Implementation | **Last Updated:** 2025-12-24
