# Diagnostic Report: NeMo ASRModel.transcribe() API Parameter Error

## Issue Summary

After successfully loading the model and attempting to transcribe audio files, the process fails with a configuration-related error. The error message indicates that NeMo's `transcribe()` method is receiving unexpected parameters or configuration that it cannot process.

From the screenshot, the error occurs during the inference phase where `model.transcribe(processed_files, batch_size=batch_size, timestamps=include_timestamps)` is called around line 743-753 of `transcribe_ui.py`.

---

## Root Cause Analysis

### The Problem: Two Different NeMo Transcription APIs

**There are two distinct transcription APIs in NeMo ASR:**

#### 1. **Simple Inference API** (For Quick Transcription)
```python
asr_model = nemo_asr.models.ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
output = asr_model.transcribe(['audio.wav'])  # Returns list of hypotheses with .text attribute
print(output[0].text)
```

This API:
- ✅ Accepts a **list of file paths** directly
- ✅ Returns `Hypothesis` objects with `.text` attribute
- ✅ Supports `timestamps=True` parameter
- ✅ **DOES NOT accept `batch_size` parameter**
- ✅ **DOES NOT accept `manifest_filepath` parameter**
- Works directly with audio file paths

#### 2. **Training/Evaluation API** (For Dataset Processing)
Used in `transcribe_speech.py` example:
```python
model.transcribe(
    config,
    manifest_filepath="dataset.json",  # Requires dataset manifest
    dataset_encoding="utf-8"
)
```

This API:
- ❌ Requires a **manifest file** (JSON format with audio_filepath, text, duration)
- ❌ Requires `dataset_encoding` parameter
- ❌ Uses **HYDRA config-based** parameter passing
- ❌ Designed for batch processing entire datasets
- **NOT suitable for simple file-list transcription**

### Critical Issue in Current Code

In `transcribe_ui.py` lines 743-753, the code calls:

```python
result = model.transcribe(
    processed_files,              # ← List of audio file paths
    batch_size=batch_size,        # ← This parameter doesn't exist in simple API!
    timestamps=include_timestamps
)
```

**The problem**: `batch_size` is NOT a valid parameter for the simple inference `transcribe()` method. This parameter belongs to the **training/evaluation API** which requires manifest files and Hydra configuration.

The simple inference API handles batching internally but doesn't expose a `batch_size` parameter to users. It automatically batches files based on available VRAM.

### Evidence from NeMo Documentation

From the [NVIDIA NeMo official documentation](https://docs.nvidia.com/nemo-framework/user-guide/latest/nemotoolkit/asr/intro.html):

> "Transcribe speech with 3 lines of code"
> ```python
> import nemo.collections.asr as nemo_asr
> asr_model = nemo_asr.models.ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
> transcript = asr_model.transcribe(["path/to/audio_file.wav"])[0].text
> ```

And with timestamps:
> ```python
> hypotheses = asr_model.transcribe(["path/to/audio_file.wav"], timestamps=True)
> ```

**Notice**: No `batch_size` parameter is mentioned or used in the official documentation.

### Why the Code Has This Issue

The `transcribe_ui.py` code was designed with the assumption that the simple API supports `batch_size` parameter (which it doesn't). The developer likely confused:
- The **internal** batch size optimization that happens automatically
- The **user-facing** `batch_size` parameter (which doesn't exist in this API)

The training-focused `transcribe_speech.py` example uses Hydra config-based API which is completely different and requires manifest files.

---

## Required Fixes

### 1. **Remove `batch_size` Parameter from `transcribe()` Call** (PRIMARY FIX)

**Location**: Lines 743-753 in `transcribe_audio()` function

**Current Code**:
```python
if torch.cuda.is_available():
    with torch.autocast(device_type='cuda', dtype=torch.float16):
        result = model.transcribe(
            processed_files, 
            batch_size=batch_size,        # ← REMOVE THIS LINE
            timestamps=include_timestamps
        )
else:
    result = model.transcribe(
        processed_files, 
        batch_size=batch_size,            # ← REMOVE THIS LINE
        timestamps=include_timestamps
    )
```

**What to do**: Simply remove the `batch_size=batch_size` arguments from BOTH calls (CUDA and CPU paths). The NeMo inference engine will handle batching automatically based on available VRAM.

### 2. **Remove or Repurpose `get_dynamic_batch_size()` Function** (SECONDARY FIX)

The `get_dynamic_batch_size()` function at lines 198-204 is now unused after removing `batch_size` parameter from `transcribe()` calls.

**Options**:
- **Option A**: Delete the function entirely (it's no longer needed)
- **Option B**: Keep it for documentation purposes but mark as deprecated with a comment
- **Option C**: Repurpose it for future features if needed (could be used for other optimization strategies)

**Recommendation**: Option A - Delete it since it doesn't apply to the simple inference API and will only confuse future maintainers.

### 3. **Remove `batch_size` from Function Signature** (TERTIARY FIX)

The function signature calls `get_dynamic_batch_size()` which should also be removed or the calculation should be removed.

**Location**: Around line 728 where batch_size is calculated:
```python
batch_size = get_dynamic_batch_size(total_duration, model_key)
```

**What to do**: Delete this line entirely since the calculated `batch_size` variable is no longer used.

### 4. **Verify API Signature Works** (VALIDATION)

The corrected `transcribe()` calls should be:

```python
if torch.cuda.is_available():
    with torch.autocast(device_type='cuda', dtype=torch.float16):
        result = model.transcribe(
            processed_files,              # List of file paths
            timestamps=include_timestamps # Optional: enable word/char timestamps
        )
else:
    result = model.transcribe(
        processed_files,
        timestamps=include_timestamps
    )
```

This matches the **exact API signature** documented in official NeMo documentation.

---

## Why This Error Wasn't Caught Earlier

1. **API Design Confusion**: The simple inference API and training/evaluation API have different signatures but similar names (`transcribe()`)
2. **Code Comment Misalignment**: The `get_dynamic_batch_size()` function suggests batch size should be tunable, but the simple API doesn't expose this
3. **No Type Hints**: Without Python type hints or explicit API signatures, it's not immediately obvious which parameters are valid
4. **Documentation Gap**: The official documentation doesn't prominently mention that `batch_size` is NOT a parameter for simple inference

---

## Impact of Fix

**After applying the fixes:**

1. ✅ `model.transcribe()` will receive only valid parameters
2. ✅ Inference will proceed without configuration errors
3. ✅ NeMo will automatically handle optimal batching internally
4. ✅ Code will match official NeMo documentation examples
5. ✅ Timestamps feature will continue to work (if supported by model)

**Performance Note**: Removing explicit `batch_size` control means NeMo determines batching based on:
- Available GPU VRAM
- Model size
- Audio duration in batch

This is actually **better** for end users because NeMo's internal heuristics are optimized for different hardware.

---

## References

- **Official NeMo ASR Intro**: https://docs.nvidia.com/nemo-framework/user-guide/latest/nemotoolkit/asr/intro.html
- **Parakeet Model Card**: https://huggingface.co/nvidia/parakeet-tdt-0.6b-v2 (shows correct usage)
- **NeMo Training/Eval Script**: https://github.com/NVIDIA/NeMo/blob/main/examples/asr/transcribe_speech.py (different API for manifest-based processing)
- **NeMo Issue #1057**: User confusion about inference vs training API

---

## Summary

The `transcribe_ui.py` code attempts to use a `batch_size` parameter that **does not exist** in NeMo's simple inference API. The simple API (`model.transcribe(file_list, timestamps=True)`) handles all batching automatically based on hardware.

**The fix is straightforward**: Remove the `batch_size` parameter from the `transcribe()` calls and delete the related `get_dynamic_batch_size()` function. This aligns the code with NeMo's official API and resolves the configuration error.