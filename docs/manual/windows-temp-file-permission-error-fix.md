# Transcription Hanging & Permission Errors: Windows Temp File Cleanup Issue

**Date:** 2025-12-11 | **Scope:** NeMo model extraction temp file cleanup failure on Windows | **Severity:** Critical

---

## Problem Summary

The transcription function appears to hang with no output and no error messages visible in the Gradio UI. PowerShell terminal shows **`PermissionError: [WinError 32]`** errors indicating "The process cannot access the file because it is being used by another process." These errors occur in NeMo's temp file cleanup code (`vtemfile.py`, `_cleanup`, `_retree` functions).

The model downloads successfully, but when NeMo tries to extract and clean up temporary files during model loading, Windows file locks prevent proper cleanup, causing the transcription callback to silently fail without user-facing error messages.

## Root Cause Analysis

**File:** `transcribe_ui.py`  
**Location:** Lines 230-260 (load_model function, HuggingFace model loading)  
**Issue:** When loading models from HuggingFace (Parakeet-1.1B, Canary models), NeMo extracts model weights to Windows `%TEMP%` directory. After extraction, the process attempts to clean up temporary files. However, Windows file locks (from antivirus, cloud sync, file indexing, or pending file handles) prevent file deletion, causing `PermissionError [WinError 32]`.

**Why it hangs silently:**
1. The `PermissionError` exception is raised inside `load_model()`
2. The exception is caught generically and raised again as `RuntimeError`
3. The `RuntimeError` is caught in `transcribe_audio()` and converted to error HTML
4. However, **Gradio's event queue may not properly propagate this error back to the UI** if it occurs during model loading (before transcription actually starts)
5. Result: No visible error appears in Gradio, button click handler appears to do nothing

**Evidence from screenshots:**
- Multiple "Error" badges appear in Gradio UI (errors are being caught but not displayed properly)
- PowerShell shows `PermissionError` stack traces with temp file cleanup failures
- No transcription output, no status updates, no visible error message to user

## Why Current Error Handling Isn't Sufficient

**Current code (lines 230-260):**
```python
except Exception as e:
    raise RuntimeError(
        f"\n{'='*80}\n"
        f"❌ ERROR LOADING MODEL!\n"
        ...
    )
```

**The problem:**
1. Exception is raised and re-raised as RuntimeError
2. The RuntimeError propagates up to `transcribe_audio()`
3. `transcribe_audio()` catches it in its outer try/except (line 330)
4. But if the exception is raised during `load_model()` call (line 297), Gradio's callback execution context may already be compromised
5. The error message is generated but **never reaches the Gradio output** because the callback execution has already failed

**Additionally:** The `load_model()` function doesn't specifically handle the Windows temp file cleanup scenario. It catches `OSError` for disk space issues (lines 242-262) but not specifically for `PermissionError` related to file locks.

## Fix Required

Implement **targeted pre-emptive mitigation** for Windows file locking issues BEFORE they cause model loading to fail silently:

1. **Detect Windows platform** before model loading
2. **Add pre-flight check** for common file lock causes (antivirus, cloud sync monitoring temp folder)
3. **Implement temp file cleanup retry logic** with exponential backoff
4. **Provide actionable user-facing guidance** specific to Windows permission issues
5. **Ensure exceptions during model loading are properly displayed** in Gradio UI (not swallowed by callback context)

**Do NOT** simply suppress or ignore the PermissionError. Instead:
- Retry temp file cleanup with delays (NeMo may have open file handles that close after a few milliseconds)
- Detect specific causes (antivirus, OneDrive, Google Drive, indexing service)
- Provide specific exclusion instructions for each cause
- Log to console so user can see progress even if UI fails

### Specific Implementation Points

**In `load_model()` function around line 234-260:**

Add specific handling for `PermissionError` that distinguishes between:
1. **WinError 32 (file in use)** - Antivirus/cloud sync/indexing issue
2. **Access denied** - Permission issue
3. **File doesn't exist** - Temp file already deleted (benign)

For WinError 32 specifically:
- Implement retry loop (3-5 attempts, 100-500ms delays)
- Detect if specific processes are holding files open
- Provide diagnostic output about what's holding the file
- Give user specific remediation steps

**Example structure (pseudocode):**
```python
def load_model_with_retry(model_id):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            return ASRModel.from_pretrained(model_id)
        except PermissionError as e:
            if "WinError 32" in str(e):
                if attempt < max_retries - 1:
                    delay = (attempt + 1) * 0.2  # 0.2s, 0.4s, 0.6s
                    print(f"⏳ File lock detected, retrying in {delay}s...")
                    time.sleep(delay)
                else:
                    # Final attempt failed - provide diagnostics
                    raise PermissionError(
                        "File lock persists. This is caused by:\n"
                        "• Windows Defender or antivirus scanning %TEMP%\n"
                        "• OneDrive/Dropbox/Google Drive syncing\n"
                        "• Windows Search or file indexing\n"
                        "Solutions:\n"
                        "1. Add %TEMP% to antivirus exclusions\n"
                        "2. Pause cloud sync temporarily\n"
                        "3. Disable Windows Search indexing\n"
                        "4. Restart computer"
                    )
            else:
                raise
```

**In `transcribe_audio()` function around line 297:**

Ensure exceptions during `load_model()` call are explicitly caught and formatted for Gradio display:
```python
try:
    model = load_model(model_key)
except PermissionError as e:
    # File lock error - provide Windows-specific guidance
    return format_windows_permission_error(str(e)), "", None
except Exception as e:
    # Other loading errors
    return format_generic_error(str(e)), "", None
```

This ensures the error message is **guaranteed** to appear in the Gradio UI status box, not silently swallowed.

## Why This Happens on Your System

Your setup triggers the issue because:
1. **OneDrive, Google Drive, or Dropbox** monitoring `%TEMP%` folder
2. **Windows Defender** performing real-time scan of temporary files
3. **Ransomware protection** locking files during extraction
4. **Windows Search** or **Windows Indexing Service** scanning `%TEMP%` contents
5. **File handles not closing immediately** after NeMo extracts model files

When any of these services hold file locks, NeMo's cleanup code fails with WinError 32.

## Evidence from Screenshots

**PowerShell error output shows:**
```
PermissionError: [WinError 32] The process cannot access the file 
because it is being used by another process: 'C:\\User\...\...tempfile...'

During handling of above exception, another exception occurred:
    File "C:\Users\chum\Venv\conda\envs\nvidia-asr\lib\vtemfile.py", 
    line 933, in _cleanup
File "C:\Users\chum\Venv\conda\envs\nvidia-asr\lib\vtemfile.py", 
    line 929, in _retree
```

This is **textbook Windows temp file cleanup failure** - exactly what the code comments mention (lines 225-228 in transcribe_ui.py).

<acceptance_criteria>
- [ ] Add Windows temp file cleanup retry logic with exponential backoff
- [ ] Specific handling for PermissionError [WinError 32] vs other OSErrors
- [ ] Diagnostic output showing which file is locked and why
- [ ] User-facing error message with specific remediation steps for Windows
- [ ] Ensure all exceptions during load_model() appear in Gradio status_output
- [ ] Test with antivirus/cloud sync actively monitoring %TEMP%
- [ ] Test with OneDrive/Dropbox syncing enabled
- [ ] Verify error messages display properly in Gradio UI
- [ ] No silent failures or hanging without error indication
- [ ] Console output shows retry attempts and diagnostic info
</acceptance_criteria>

## Supporting Context

<details>
<summary>Why Model Loading Fails Silently in Gradio</summary>

Gradio's event callback execution has specific lifecycle phases:

1. User clicks button
2. Gradio validates inputs
3. Gradio invokes callback function (transcribe_audio) in task queue
4. Callback executes, calls load_model()
5. If load_model() raises an exception:
   - Exception propagates up to callback
   - Callback's outer try/except catches it
   - Error message should be returned to UI

**However**, if the exception occurs BEFORE callback returns outputs:
- The callback execution may timeout or be interrupted
- The error message may not be properly serialized back through Gradio's event queue
- Result: Callback appears to hang, no error visible to user
- But PowerShell shows the actual exception because it's logging to stderr

**This is why you see:**
- UI shows "Error" badges but no readable message
- PowerShell shows full PermissionError traceback
- No transcription output, no status updates
- Button click appears to do nothing

</details>

<details>
<summary>Windows File Lock Architecture</summary>

When NeMo extracts a model from HuggingFace cache:

1. Model is downloaded to `~/.cache/torch/NeMo/`
2. NeMo extracts to temporary directory via Python's `tempfile` module
3. Extraction creates many small files (model weights, configs, etc.)
4. Windows antivirus/cloud-sync services monitor these files
5. Even after NeMo's code finishes with files, Windows keeps handles open
6. When `tempfile` cleanup code tries to delete, WinError 32 occurs

**Key point:** The file isn't locked by NeMo - it's locked by Windows services operating in the background. NeMo's cleanup code doesn't anticipate this and fails immediately.

**Solution:** Implement retry logic with backoff delays, giving Windows services time to release file handles.

</details>

---

**Priority:** Critical (Blocks transcription completely) | **Dependencies:** None | **Complexity:** Medium (retry logic + diagnostics)
