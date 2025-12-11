# Diagnostic Report: NeMo Transcription Failing Due to Incorrect API Usage and Gradio Integration Issues

**Date:** December 11, 2025 | **Severity:** Critical | **Type:** API Misuse + Integration Bug

---

## Executive Summary

The Gradio interface fails to transcribe audio despite successful model loading. The root cause is **NOT file locking** as previously diagnosed, but rather **two distinct problems:**

1. **Incorrect `batch_size` usage in `transcribe()` calls** - The simple inference API's `batch_size` parameter works differently than implemented
2. **Timestamp object handling bug** - The code attempts to access `.words` attribute that doesn't exist on Hypothesis objects, causing runtime errors

These issues prevent any transcription from completing successfully, even though the model loads correctly.

---

## Issue #1: Incorrect Batch Size Parameter Usage

### Problem
Transcriptions fail during the inference phase with configuration errors related to batch size handling.

### Root Cause

**File:** `transcribe_ui.py`  
**Location:** `transcribe_audio()` function, lines 1131-1140  
**Issue:** The code passes `batch_size` as a positional/keyword argument to `transcribe()`, but the NeMo simple inference API handles batch sizing differently than the training/evaluation API.

**Current Code:**
```python
if torch.cuda.is_available():
    with torch.autocast(device_type='cuda', dtype=torch.float16):
        result = model.transcribe(
            processed_files, 
            batch_size=batch_size,        # ← PROBLEMATIC
            timestamps=include_timestamps
        )
else:
    result = model.transcribe(
        processed_files, 
        batch_size=batch_size,            # ← PROBLEMATIC
        timestamps=include_timestamps
    )
```

**Why This Fails:**
According to official NeMo documentation (https://docs.nvidia.com/nemo-framework/user-guide/latest/nemotoolkit/asr/intro.html), the simple inference `transcribe()` method accepts `batch_size` parameter, BUT the way batch sizing is calculated in `get_dynamic_batch_size()` function (lines 285-293) uses audio duration-based heuristics that don't align with how NeMo actually handles batching internally.

The inference engine doesn't process audio in temporal batches like the training/evaluation API does. Instead, it:
- Automatically batches file lists based on available VRAM
- Doesn't expose manual batch size tuning to simple inference users
- Has internal logic that may conflict with user-provided batch sizes

**Symptom in Logs:**
The PowerShell logs (Screenshot-199.jpg through 202.jpg) show the code reaching the transcription attempt but then failing with configuration warnings about ignored parameters and tokenization issues.

### Fix Required

The `get_dynamic_batch_size()` function should be repurposed or removed. Instead of passing a calculated `batch_size`, the transcribe call should use NeMo's automatic batching by either:

1. **Removing `batch_size` parameter entirely** - Let NeMo handle optimal batching automatically based on VRAM
2. **OR using NeMo's documented default** - Pass `batch_size=4` (the default) explicitly only if needed, without the duration-based calculation

The current implementation of `get_dynamic_batch_size()` (lines 285-293) attempts to tune batch size based on audio duration (8/16/24/32 based on duration ranges), but this doesn't match how NeMo's inference engine actually works. This function should be removed entirely, as it creates a false expectation of batch size control that the simple inference API doesn't provide.

---

## Issue #2: Invalid Timestamp Object Attribute Access

### Problem
Even if transcription succeeds, the code crashes when trying to display timestamps because it accesses a `.words` attribute that doesn't exist.

### Root Cause

**File:** `transcribe_ui.py`  
**Location:** `transcribe_audio()` function, lines 1178-1184  
**Issue:** The code assumes result objects have a `.words` attribute with timestamp data, but NeMo's Hypothesis objects don't expose this interface.

**Current Code:**
```python
if include_timestamps and hasattr(result[0], 'words') and result[0].words:
    timestamp_text = "\n\n### Word-Level Timestamps (first 50 words):\n\n"
    for i, word in enumerate(result[0].words[:50]):
        timestamp_text += f"`{word.start:.2f}s - {word.end:.2f}s` → **{word.text}**\n\n"
```

**Why This Fails:**
According to NeMo documentation (https://github.com/NVIDIA/NeMo/blob/main/docs/source/asr/intro.rst), timestamp data is accessed via the `timestamp` dictionary attribute, NOT via a `.words` attribute:

```python
# Correct approach from official docs:
hypotheses = asr_model.transcribe([...], timestamps=True)
word_timestamps = hypotheses[0].timestamp['word']  # Access via dictionary key
```

The Hypothesis object structure is:
- `.text` - transcribed text
- `.timestamp` - dictionary containing 'char', 'word', and 'segment' keys
- Each timestamp entry is a dictionary with `'start'`, `'end'`, `'segment'` (not `.start`, `.end`, `.text` as attributes)

The code will fail at runtime because:
1. `hasattr(result[0], 'words')` returns False (attribute doesn't exist)
2. Even if it returned True, `result[0].words` would raise AttributeError
3. The loop expects objects with `.start`, `.end`, `.text` but receives dictionaries with different structure

### Fix Required

Replace the timestamp handling logic to:
1. Check for `timestamp` dictionary instead of `.words` attribute
2. Access timestamp data using dictionary keys (`['word']`, `['char']`, etc.) instead of object attributes
3. Extract `'start'`, `'end'`, `'segment'` from dictionaries using proper dictionary access syntax
4. Follow the exact pattern from official NeMo documentation for timestamp extraction and display

---

## Issue #3: File Caching Not Being Used

### Problem
Despite the cache directory infrastructure (`_gradio_cache_dir`, `copy_gradio_file_to_cache()`), the file copying appears to have issues or isn't being validated.

### Root Cause

**File:** `transcribe_ui.py`  
**Location:** `transcribe_audio()` function, lines 1099-1109  
**Issue:** The `copy_gradio_file_to_cache()` function (lines 239-278) may fail silently or return paths that don't exist when checked by librosa.

The file copying logic uses hashed filenames and caching, but:
1. The retry logic has a maximum of 3 attempts with only linear backoff (0.2s → 0.4s → 0.6s)
2. If Windows file locks persist beyond 0.6 seconds, the copy fails and raises an error that propagates to Gradio
3. The cached file path is returned but may not be immediately readable due to antivirus scanning delays

**Current Retry Logic:**
```python
base_delay = 0.2  # 200ms base delay
for attempt in range(max_retries):
    try:
        shutil.copy2(file_path, cached_path)
        return str(cached_path)
```

**Why This Fails:**
- Windows antivirus (Defender, Norton, etc.) may hold file locks for > 600ms
- The retry delays are too short for real-world Windows file lock scenarios
- Once file is copied, librosa.get_duration() might also hit file locks immediately after

### Fix Required

Increase retry delays and add more robust wait logic:
1. Use exponential backoff instead of linear (0.5s → 1.0s → 1.5s → 2.0s minimum)
2. Increase `max_retries` from 3 to at least 5-6 attempts
3. Add validation that file was actually written and is readable before returning path
4. Apply same retry logic to `librosa.get_duration()` call, not just file copying

---

## Shared Implementation Context

All three issues stem from:
1. **Incomplete API documentation absorption** - The code was written against training/evaluation examples rather than simple inference examples
2. **Incomplete error handling** - Failures in transcription don't surface useful diagnostics to Gradio UI
3. **Incomplete retry strategy** - File locking issues remain despite environment variable configuration

---

## Acceptance Criteria

- [ ] `batch_size` parameter removed from transcribe calls OR replaced with NeMo default value (4)
- [ ] `get_dynamic_batch_size()` function deleted entirely (lines 285-293)
- [ ] Timestamp display code uses `result[0].timestamp['word']` dictionary access pattern (NOT `.words` attribute)
- [ ] Timestamp dictionaries unpacked correctly: `stamp['start']`, `stamp['end']`, `stamp['segment']`
- [ ] File copy retry logic uses exponential backoff with minimum 2.0 second maximum delay
- [ ] `librosa.get_duration()` also wrapped in retry logic (currently only file copy has retries)
- [ ] Test transcription: upload single WAV file → transcribe → results appear in UI without errors
- [ ] Test timestamps: enable timestamp checkbox → transcription includes word timestamps
- [ ] Test batch: upload 3 audio files → batch transcription completes successfully
- [ ] All error messages properly formatted for Gradio markdown display

---

## Supporting Evidence

### From Screenshots:
- **Screenshot-198, 197**: Gradio UI shows "Transcription Failed: File Lock Error" - indicates failure after model loading
- **Screenshot-200**: PowerShell logs show model loads successfully, but no transcription output appears
- **Screenshot-199**: Logs show tokenization warnings and configuration ignored messages (batch_size related)

### From Code Review:
- Lines 285-293: `get_dynamic_batch_size()` uses duration-based calculations not supported by inference API
- Lines 1131-1140: `batch_size=batch_size` passed to transcribe without validation
- Lines 1178-1184: `.words` attribute access on Hypothesis objects that use `.timestamp` dictionary instead
- Line 1106: `librosa.get_duration()` NOT wrapped in retry logic, vulnerable to file locks

---

## References

- **Official NeMo ASR Intro:** https://docs.nvidia.com/nemo-framework/user-guide/latest/nemotoolkit/asr/intro.html
- **Official NeMo API:** https://docs.nvidia.com/nemo-framework/user-guide/24.09/nemotoolkit/asr/api.html
- **Parakeet Timestamps Example:** https://huggingface.co/nvidia/parakeet-tdt-0.6b-v2
- **NeMo GitHub Intro Docs:** https://github.com/NVIDIA/NeMo/blob/main/docs/source/asr/intro.rst
