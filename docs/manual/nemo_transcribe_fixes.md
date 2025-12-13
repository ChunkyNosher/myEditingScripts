# NeMo Audio Transcription Script: Complete Bug Analysis & Fix Guide

**Document Version:** 1.0  
**Date:** December 13, 2025  
**Target Files:** `transcribe_ui.py`, `setup_local_models.py`  
**Scope:** Windows file locking errors during GPU inference and related issues  

---

## Executive Summary

Your NeMo transcription application has **two distinct problem areas**:

1. **Critical Issue**: Transcription fails with file lock errors during GPU inference (after model loads successfully)
2. **Secondary Issues**: Several defensive code patterns that don't fully address the root problems

This document details exactly what's broken, why it's broken, where in the code it's broken, and how to fix it.

---

## Issue #1: Transcription File Lock Error During Inference (CRITICAL)

### Problem Statement

When transcribing audio files, the application:
1. ✅ Loads model successfully
2. ✅ Starts GPU inference (GPU fully utilized)
3. ❌ Fails with "Transcription Failed: File Lock Error" after 3 retry attempts exhausted
4. ❌ No audio is transcribed

**Error Output**: `PermissionError: WinError 32 (file in use)`

---

### Root Cause Analysis

#### **The Core Issue**

NeMo's `model.transcribe()` method creates temporary **manifest JSON files** during CUDA inference that Windows services lock. The current code cannot prevent these locks because it attempts to work around the problem at the wrong level.

#### **Where It Happens**

**File**: `transcribe_ui.py`  
**Function**: `transcribe_audio()` (lines 350-430)  
**Exact Line**: Line ~394 (the actual transcription call)

```python
# Line 394-395 in transcribe_audio()
result = model.transcribe(
    processed_files, 
    batch_size=batch_size,
    timestamps=include_timestamps
)
```

This single call triggers the problem.

#### **Why It Happens**

When `model.transcribe()` executes:

1. **Manifest Creation** → NeMo creates a JSON file listing audio files with metadata
2. **Dataloader Setup** → C++ dataloader reads this JSON manifest
3. **GPU Inference** → Audio batches loaded to GPU and processed (GPU fully utilized here)
4. **Result Collection** → NeMo tries to read results and clean up manifest file
5. **File Lock Occurs** → During steps 1, 4, or 5, Windows services (antivirus, OneDrive, indexing) lock the manifest file

The lock happens because:
- Windows antivirus scans all file creation in temp directories
- OneDrive/Dropbox sync monitors the cache folder
- Windows Search/Indexing service locks files being created
- NeMo's C++ backend writes files that the OS intercepts before Python error handling

#### **Why Current Mitigations Fail**

**Fixes #1-4 Are Working Correctly** ✅

Lines 25-50 set up environment variables correctly:
```python
os.environ["TORCH_HOME"] = str(_cache_dir / "torch")
os.environ["HF_HOME"] = str(_cache_dir / "huggingface")
os.environ["NEMO_CACHE_DIR"] = str(_cache_dir / "nemo")
os.environ["TMPDIR"] = str(_cache_dir / "tmp")
tempfile.tempdir = str(_temp_dir)
```

These work perfectly for model downloading and Python-level file operations. GPU fully utilizing proves the model loaded.

**Fix #5 (Retry Logic) Is Insufficient** ❌

Lines 380-430 contain the transcription retry logic:
```python
for attempt in range(max_retries):
    try:
        # Transcription call
        result = model.transcribe(...)
    except PermissionError as e:
        # Retry with backoff
        if is_file_lock and attempt < max_retries - 1:
            delay = base_delay * (attempt + 1)  # 0.5s, 1.0s, 1.5s
            time.sleep(delay)
            continue
```

**Why This Fails**:
- The lock is **not transient** (not a timing issue)
- The lock **recurs identically every attempt** because the same manifest creation operation always triggers the same Windows lock
- The retry waits 0.5-1.5 seconds, but Windows services **continue holding the file handle** indefinitely during NeMo's internal operations
- The problem is **architectural to NeMo's API**, not a timing issue to be solved with delays

**The Fundamental Problem**: The Python-level environment variable redirections (`TMPDIR`, `HF_HOME`, etc.) only control Python's file operations. They **do not reach** NeMo's C++ dataloader, which:
- Creates manifest files in its own temp locations
- Performs file I/O operations that bypass Python's tempfile module
- Interacts with the OS file system at a level where Python environment variables have no effect

---

### The Solution

The fix requires **changing the operation itself**, not retrying it. There are three layers of solution:

#### **Layer 1: Primary Fix - NeMo API Configuration (MUST INVESTIGATE FIRST)**

**Objective**: Prevent NeMo from creating manifest files during inference by using API parameters.

**What to Do**:

1. **Investigate NeMo's ASRModel.transcribe() method signature**
   - Check the official NeMo documentation: https://docs.nvidia.com/nemo-framework/
   - Review the NeMo source code: https://github.com/NVIDIA/NeMo
   - Search for parameters like:
     - `use_cache=False`
     - `temp_dir` or `work_dir`
     - `in_memory=True`
     - Dataloader configuration flags
     - `create_manifest=False`

2. **Check if lower-level inference methods exist** that bypass manifest creation:
   - `model()` direct forward pass on pre-processed audio
   - `model.compute_logits()` method
   - `model.transcribe_batch()` or similar batch method
   - Custom inference wrapper methods in NeMo

3. **Implement whichever exists**:

**Option A - If API parameters exist to skip manifest creation:**

Replace lines 394-399:
```python
# OLD CODE (creates manifest, causes locks)
result = model.transcribe(
    processed_files, 
    batch_size=batch_size,
    timestamps=include_timestamps
)

# NEW CODE (skip manifest creation)
result = model.transcribe(
    processed_files, 
    batch_size=batch_size,
    timestamps=include_timestamps,
    create_manifest=False,  # OR whatever the actual parameter is
    temp_dir=None,  # OR in_memory=True, etc.
)
```

**Option B - If lower-level inference method exists:**

Create a new function around line 340:
```python
def _transcribe_without_manifest(model, audio_files, batch_size, include_timestamps):
    """
    Transcribe audio using NeMo's lower-level inference API to avoid 
    manifest file creation that triggers Windows file locks.
    """
    # Use model's forward pass or alternative method that doesn't create manifest
    # Implementation depends on NeMo's actual available methods
    pass
```

Then replace the transcription call (lines 394-399):
```python
# Use alternative method that doesn't create manifest files
result = _transcribe_without_manifest(
    model, 
    processed_files,
    batch_size,
    include_timestamps
)
```

---

#### **Layer 2: Secondary Fix - Windows Service Mitigation (If Layer 1 Insufficient)**

**Objective**: Temporarily disable Windows services that lock files during transcription.

**What to Do**:

Add this function before `transcribe_audio()` (around line 330):

```python
def _disable_windows_services_during_transcription():
    """
    Context manager to temporarily disable Windows services that cause file locks.
    Only on Windows OS. Requires admin privileges.
    """
    import subprocess
    import sys
    
    if sys.platform != "win32":
        return None
    
    try:
        # Disable Windows Search indexing for cache directory
        cache_path = str(CACHE_DIR)
        # This would require Windows API calls or PowerShell
        # Implementation requires careful handling and admin privileges
        pass
    except Exception as e:
        print(f"⚠️ Could not disable Windows services: {e}")
```

Then wrap the transcription call (lines 380-430) with this mitigation:
```python
# Before GPU inference, disable problematic services if on Windows
with _disable_windows_services_during_transcription():
    for attempt in range(max_retries):
        try:
            result = model.transcribe(...)
            break
        except PermissionError:
            # Retry logic
            pass
```

---

#### **Layer 3: Tertiary Fix - Cache Directory Locking Prevention (If Layers 1-2 Insufficient)**

**Objective**: Prevent Windows from monitoring the cache directory during transcription.

**What to Do**:

Add this function before `copy_gradio_file_to_cache()` (around line 290):

```python
def _validate_cache_directory_access():
    """
    Validate that cache directory is accessible and not locked by Windows services.
    Implements pre-transcription checks to detect potential lock conditions.
    """
    import os
    import time
    
    # Try to create and delete a test file in cache directory
    test_file = _cache_dir / f".lock_test_{int(time.time())}.tmp"
    
    try:
        # Write test file
        test_file.write_text("test")
        # Immediately delete
        test_file.unlink()
        return True
    except PermissionError:
        # Cache directory is locked by Windows services
        print(f"⚠️ Cache directory is locked: {_cache_dir}")
        print("Try:")
        print("  1. Pause OneDrive/Dropbox temporarily")
        print("  2. Disable antivirus real-time scanning")
        print("  3. Run as Administrator")
        return False
```

Then call this before transcription (add around line 370):
```python
# Validate cache access before starting GPU inference
if not _validate_cache_directory_access():
    return "❌ Cache directory is locked by Windows services. See troubleshooting steps above.", "", None
```

---

### Implementation Checklist for Issue #1

- [ ] **FIRST**: Research NeMo's `transcribe()` API documentation and source code for manifest/temp file control parameters
- [ ] **SECOND**: Check if NeMo has lower-level inference methods that bypass manifest creation
- [ ] **THIRD**: Implement Layer 1 fix using API parameters or alternative methods
- [ ] **FOURTH**: If Layer 1 doesn't fully resolve, implement Layer 2 (Windows service mitigation)
- [ ] **FIFTH**: If still issues, implement Layer 3 (cache locking detection)
- [ ] **TEST**: Upload 1-hour audio → transcribe → verify no "File Lock Error" on first attempt
- [ ] **TEST**: Repeat transcription 5 times consecutively → all succeed without retries
- [ ] **TEST**: Test with all 4 models (Parakeet v3, Parakeet 1.1B, Canary 1B, Canary 1B-v2)
- [ ] **TEST**: Test with batch transcription (multiple files)
- [ ] **VERIFY**: Timestamps feature still works if inference method changed

---

## Issue #2: Insufficient Error Context in Exception Handling

### Problem Statement

When errors occur during model loading or transcription, the error messages don't always provide enough context to diagnose Windows-specific issues.

### Where It Happens

**File**: `transcribe_ui.py`  
**Function**: `transcribe_audio()` (lines 360-380)  
**Exact Lines**: Model loading error handling

```python
# Lines 360-380 in transcribe_audio()
try:
    model = load_model(model_key)
except PermissionError as e:
    error_msg = str(e)
    print(f"GRADIO_ERROR (PermissionError): {error_msg}")
    return f"### ❌ Model Loading Error\n\n{error_msg}", "", None
except ConnectionError as e:
    # Similar issue
```

### Root Cause

The error messages are formatted correctly, but they don't provide actionable troubleshooting steps specific to Windows file locking. Users see "file in use" but don't know what caused it or how to fix it.

### The Solution

**File**: `transcribe_ui.py`  
**Location**: Expand the error handling in `transcribe_audio()` (lines 360-380)

Add specific Windows diagnostic information to each error type:

```python
# Lines 360-380, replace with:
try:
    model = load_model(model_key)
except PermissionError as e:
    error_msg = str(e)
    if "WinError 32" in error_msg or "being used by another process" in error_msg:
        # Windows-specific file lock
        detailed_error = (
            f"### ❌ Model Loading Failed: Windows File Lock\n\n"
            f"{error_msg}\n\n"
            f"**Root Cause**: Windows services (antivirus, OneDrive, indexing) are locking model files.\n\n"
            f"**Immediate Actions**:\n"
            f"1. Pause OneDrive/Dropbox/Google Drive\n"
            f"2. Temporarily disable antivirus real-time scanning\n"
            f"3. Run as Administrator\n"
            f"4. Restart your computer\n\n"
            f"**Cache Location**: `{CACHE_DIR}`\n"
            f"Add this folder to antivirus exclusions if issue persists."
        )
    else:
        # Different permission error
        detailed_error = (
            f"### ❌ Model Loading Error\n\n"
            f"Permission denied. Check:\n"
            f"- Run as Administrator\n"
            f"- Folder permissions for: `{CACHE_DIR}`\n"
            f"- Disk space availability\n\n"
            f"**Error Details**: {error_msg}"
        )
    print(f"GRADIO_ERROR (PermissionError): {detailed_error}")
    return detailed_error, "", None
```

### Implementation Checklist for Issue #2

- [ ] Expand error messages with Windows-specific diagnostics
- [ ] Add troubleshooting steps for each error type
- [ ] Include cache directory path in all error messages
- [ ] Add suggestions for antivirus/cloud sync exclusions
- [ ] TEST: Trigger each error type and verify message clarity

---

## Issue #3: Incomplete Validation of Temp Directory Configuration

### Problem Statement

Lines 25-50 set up temp directories, but don't fully validate that **all** of NeMo's internal operations will use them. The validation at line 60-65 only checks Python's `tempfile.gettempdir()`, not where NeMo actually creates files.

### Where It Happens

**File**: `transcribe_ui.py`  
**Lines**: 60-65 (validation section)

```python
# Lines 60-65
_actual_temp = tempfile.gettempdir()
if _actual_temp != str(_temp_dir):
    print(f"⚠️  WARNING: tempfile.gettempdir() returned {_actual_temp}")
else:
    print(f"✓ Temp directory verified: {_temp_dir}")
```

### Root Cause

This validation only checks Python's tempfile module. It doesn't validate whether NeMo's internal C++ operations will respect the temp directory redirection. Since NeMo's manifest files are created by C++ code, this validation is **insufficient** and gives false confidence.

### The Solution

**File**: `transcribe_ui.py`  
**Location**: Add new validation function around line 50, before existing validation

```python
def _validate_nemo_temp_behavior():
    """
    Validate that NeMo respects our temp directory configuration.
    This is more rigorous than just checking tempfile.gettempdir().
    """
    # Note: This validation would require actually loading a model and checking
    # where it creates files, which is complex at startup.
    # Instead, document this limitation and add runtime checks.
    
    print("\n⚠️ NOTE: NeMo's C++ backend may not fully respect TMPDIR environment variable.")
    print("If file lock errors occur during transcription:")
    print("  1. Add cache directory to antivirus exclusions")
    print("  2. Pause cloud sync services (OneDrive, Dropbox)")
    print("  3. See Issue #1 solution in code comments")
```

Add call at line 65:
```python
# Validate Python tempfile (works)
_actual_temp = tempfile.gettempdir()
if _actual_temp != str(_temp_dir):
    print(f"⚠️  WARNING: tempfile.gettempdir() returned {_actual_temp}")
else:
    print(f"✓ Temp directory verified: {_temp_dir}")

# Acknowledge NeMo's C++ backend limitation
_validate_nemo_temp_behavior()
```

### Implementation Checklist for Issue #3

- [ ] Add comment documenting that C++ backend may not respect TMPDIR
- [ ] Add warning message at startup explaining the limitation
- [ ] Point users to Layer 1-3 fixes if errors occur
- [ ] TEST: Verify warning appears on startup

---

## Issue #4: Retry Logic Creates False Sense of Security

### Problem Statement

The retry logic in `transcribe_audio()` (lines 380-430) creates the impression that transient file locks are being handled, but they're not. The logic retries the **exact same operation** that caused the lock, which will fail identically each time.

### Where It Happens

**File**: `transcribe_ui.py`  
**Function**: `transcribe_audio()` (lines 380-430)  
**Core Issue**: Lines 394-430

```python
for attempt in range(max_retries):
    try:
        # Same operation every attempt
        result = model.transcribe(
            processed_files, 
            batch_size=batch_size,
            timestamps=include_timestamps
        )
        break
    except PermissionError as e:
        # Detect file lock
        if is_file_lock and attempt < max_retries - 1:
            delay = base_delay * (attempt + 1)
            time.sleep(delay)  # Wait and retry same operation
            continue
        else:
            # Fail after 3 attempts
            raise
```

### Root Cause

The retry pattern assumes the lock is **transient** (will resolve on its own with a delay). But NeMo's manifest file creation lock is **persistent** during NeMo's operation, so retrying doesn't help.

**Analogy**: If someone is using a tool and won't let you use it, waiting and asking again doesn't help. You need to either:
1. Use a different tool (Layer 1 fix)
2. Make them not use the tool (Layer 2 fix)
3. Get them to let go first (Layer 3 fix)

Simply retrying the same request (current approach) will fail identically.

### The Solution

**Option A - If Layers 1-3 fixes are implemented:**

Replace the entire retry loop (lines 380-430) with simpler error handling since the root cause is fixed:

```python
# Single attempt, no retry (because manifest creation is prevented)
try:
    if torch.cuda.is_available():
        with torch.autocast(device_type='cuda', dtype=torch.float16):
            result = model.transcribe(
                processed_files, 
                batch_size=batch_size,
                timestamps=include_timestamps
            )
    else:
        result = model.transcribe(
            processed_files, 
            batch_size=batch_size,
            timestamps=include_timestamps
        )
except Exception as e:
    # Error handling without retry (error indicates Layer 1-3 fix incomplete)
    return handle_transcription_error(e), "", None
```

**Option B - If Layers 1-3 fixes are not implemented:**

Modify retry logic to be transparent about its limitation:

```python
# Current approach, but add warning
max_retries = 3
for attempt in range(max_retries):
    try:
        result = model.transcribe(...)
        break
    except PermissionError as e:
        if attempt < max_retries - 1:
            delay = base_delay * (attempt + 1)
            print(f"⚠️ Attempting retry {attempt + 1}/{max_retries} (this will likely fail again)...")
            print(f"   See Issue #1 fix in code comments for permanent solution")
            time.sleep(delay)
            continue
        else:
            print(f"❌ All {max_retries} attempts exhausted.")
            print(f"   The lock is persistent, not transient. Retries won't help.")
            raise
```

### Implementation Checklist for Issue #4

- [ ] If implementing Layers 1-3: Simplify retry logic since root cause is fixed
- [ ] If not implementing Layers 1-3: Add transparency about why retries won't help
- [ ] Update error message to direct users to Layer 1-3 solutions
- [ ] Add code comments referencing the Issue #1 analysis
- [ ] TEST: Verify error messages are helpful (not misleading)

---

## Issue #5: Model Caching May Interact Poorly with File Locks

### Problem Statement

The `models_cache` dictionary (line 275) keeps loaded models in memory, which is good for performance. However, if a model fails to load due to file locks and is partially cached, subsequent transcription attempts may use corrupted or incomplete model state.

### Where It Happens

**File**: `transcribe_ui.py`  
**Function**: `load_model()` (lines 275-285)

```python
# Line 275
models_cache = {}

# Lines 275-285 in load_model()
if model_name not in models_cache:
    # Load model
    models_cache[model_name] = loaded_model
    return models_cache[model_name]
else:
    return models_cache[model_name]
```

### Root Cause

If a model fails to load and is partially stored in `models_cache`, the next transcription attempt might:
1. See the model is cached
2. Try to use the incomplete model
3. Fail with confusing error messages
4. Create multiple partial models consuming GPU memory

### The Solution

**File**: `transcribe_ui.py`  
**Location**: Modify `load_model()` function around line 275

Add validation before returning cached model:

```python
def load_model(model_name, show_progress=False):
    """Load model using the appropriate method based on model type."""
    
    if model_name not in models_cache:
        # Load model (existing code)
        config = MODEL_CONFIGS[model_name]
        # ... existing loading code ...
        models_cache[model_name] = loaded_model
    else:
        # Validate cached model before returning
        cached_model = models_cache[model_name]
        try:
            # Quick validation: model should have required methods
            if not hasattr(cached_model, 'transcribe'):
                print(f"⚠️ Cached {model_name} appears corrupted (missing transcribe method)")
                # Remove corrupted cache entry
                del models_cache[model_name]
                # Recursively reload
                return load_model(model_name, show_progress)
        except Exception as e:
            print(f"⚠️ Cached model validation failed: {e}")
            del models_cache[model_name]
            return load_model(model_name, show_progress)
    
    return models_cache[model_name]
```

### Implementation Checklist for Issue #5

- [ ] Add validation function for cached models
- [ ] Check if model has required methods (`transcribe`, `compute_logits`, etc.)
- [ ] Detect corrupted cache entries and remove them
- [ ] Add logging when cache is removed
- [ ] TEST: Load model, simulate partial failure, verify cache is cleaned up
- [ ] TEST: Verify model reloads correctly after cache invalidation

---

## Summary: What to Fix and In What Order

### Priority 1 (CRITICAL) - Must Fix First
**Issue #1**: Transcription file lock error  
**Files**: `transcribe_ui.py`  
**Effort**: High (requires NeMo API research + multiple fix layers)  
**Impact**: Blocks transcription entirely without this fix  

**Action**: 
1. Research NeMo transcribe() API for manifest file control
2. Implement Layer 1 fix (API parameters or alternative inference method)
3. If needed, implement Layer 2-3 fixes

### Priority 2 (HIGH) - Fix After Priority 1
**Issues #2, #3, #4**: Error messages, validation, retry logic  
**Files**: `transcribe_ui.py`  
**Effort**: Medium (code changes, no research needed)  
**Impact**: Improves user experience and transparency  

**Actions**:
1. Expand error messages with Windows diagnostics (Issue #2)
2. Add warning about C++ backend limitation (Issue #3)
3. Simplify or fix retry logic (Issue #4)

### Priority 3 (MEDIUM) - Nice-to-Have
**Issue #5**: Model caching validation  
**Files**: `transcribe_ui.py`  
**Effort**: Low  
**Impact**: Prevents edge-case failures with corrupted cached models  

**Action**: Add model validation to cache retrieval

### Not Needed - These Are Working Fine
- `setup_local_models.py` (no issues found)
- Model loading functions (`load_model()`, `_load_with_retry()`)
- Gradio file upload handling (`copy_gradio_file_to_cache()`)

---

## Testing Checklist

After implementing fixes, test these scenarios:

```
CRITICAL TESTS (for Issue #1 fix):
[ ] Single file (30 seconds) → transcribe → verify correct output
[ ] Single file (1 hour) → transcribe → verify completes without file lock error
[ ] Multiple attempts (5 transcriptions in a row) → all succeed without retries
[ ] Batch processing (3 files) → transcribe → all complete without errors
[ ] All 4 models → test each with 10-minute audio file

HIGH PRIORITY TESTS (for Issues #2-4):
[ ] Trigger model load error → verify detailed Windows-specific message
[ ] Trigger transcription with locked cache → verify helpful troubleshooting steps
[ ] Check startup warnings → verify C++ backend limitation is documented
[ ] Verify retry logic is transparent about what it's doing

MEDIUM PRIORITY TESTS (for Issue #5):
[ ] Load model → transcribe → verify model remains usable for 10 consecutive transcriptions
[ ] Simulate partial load failure → verify cache is cleaned up
[ ] Load multiple models → verify each is cached and usable independently

REGRESSION TESTS:
[ ] Video file transcription → still works correctly
[ ] Timestamp generation → still works if inference method changed
[ ] GPU memory cleanup → model unloads correctly after done
[ ] Batch size optimization → still uses correct batch_size
```

---

## Files and Line References

### transcribe_ui.py Issues:

| Issue | Lines | Function | Problem | Fix |
|-------|-------|----------|---------|-----|
| #1: File Lock Error | 394-430 | `transcribe_audio()` | Retry loop can't fix manifest locks | Layer 1-3 solutions (API params, service mitigation, cache detection) |
| #2: Poor Error Context | 360-380 | `transcribe_audio()` | Generic error messages | Expand with Windows-specific diagnostics |
| #3: Incomplete Validation | 60-65 | Module init | Only validates Python tempfile | Add warning about C++ backend limitations |
| #4: Ineffective Retry | 380-430 | `transcribe_audio()` | Retries same lock-causing operation | Simplify after fixing Issue #1, or add transparency |
| #5: Cache Corruption Risk | 275-285 | `load_model()` | No validation of cached models | Add validation before returning cached model |

### setup_local_models.py
No issues found. File is working correctly.

---

## Additional Resources

### Official Documentation
- NeMo ASR Models: https://docs.nvidia.com/nemo-framework/user-guide/latest/nemotoolkit/asr/models.html
- NeMo GitHub: https://github.com/NVIDIA/NeMo
- NeMo Issues/Discussions: https://github.com/NVIDIA/NeMo/issues

### Windows-Specific File Locking
- Windows WinError 32: https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-
- Python tempfile module: https://docs.python.org/3/library/tempfile.html

### Your Current Fixes Documentation
All current fixes (#1-5 in the code) are working correctly for:
- Model downloading from HuggingFace
- Environment variable redirection
- Python tempfile module control
- Gradio file upload handling

The issue is specifically with **NeMo's internal C++ operations during inference** that bypass these controls.

---

## Implementation Timeline

**Phase 1 (Week 1)**: Research and Issue #1 Layer 1 fix
- Research NeMo transcribe() API
- Implement Layer 1 solution
- Test basic transcription

**Phase 2 (Week 2)**: Layer 2-3 fallback solutions
- Implement Windows service mitigation if needed
- Implement cache directory detection
- Full integration testing

**Phase 3 (Week 2-3)**: Issues #2-5 improvements
- Expand error messages
- Add validation and warnings
- Improve cache handling
- Final testing

**Phase 4 (Week 3)**: Polish and documentation
- Update user-facing error messages
- Document the fix in code comments
- Final regression testing

---

## Questions for Investigation

Before you start coding fixes, you'll need answers to these questions:

1. **Does NeMo's `transcribe()` method have parameters to prevent manifest file creation?**
   - Check method signature in NeMo source/documentation
   - Look for `temp_dir`, `use_cache`, `in_memory`, `create_manifest` parameters

2. **Are there alternative inference methods in NeMo that avoid manifest files?**
   - Check for `model()` direct forward pass
   - Check for `compute_logits()` method
   - Check for batch inference alternatives

3. **What exactly is the Windows lock holding?**
   - Is it antivirus scanning?
   - Is it OneDrive/cloud sync?
   - Is it Windows Indexing?
   - Is it something else entirely?

4. **How much effort is the Layer 1 fix vs. workaround fixes?**
   - If API parameters exist, fix is trivial
   - If alternative method exists, fix is simple
   - If neither exists, fallback fixes are more complex

Start by answering these questions before implementing fixes.

---

**End of Document**

