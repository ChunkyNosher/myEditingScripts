# NeMo Transcription Script Loading Failures

**Extension Version:** myEditingScripts (Latest)  
**Date:** 2025-12-05

<scope>
One sentence: Two critical model loading failures preventing transcription functionality - Canary model fails with invalid git identifier error, Parakeet model fails with Windows temp file permission error.
</scope>

---

## Executive Summary

The transcription script (`transcribe_ui.py`) experiences two distinct loading failures that prevent both Parakeet and Canary models from functioning. The Canary model fails during HuggingFace download due to a malformed revision hash (31 characters instead of 40), triggering "not a valid git identifier" error. The Parakeet model successfully locates its `.nemo` file but fails during NeMo's internal extraction process with Windows-specific file locking errors (`WinError 32`) when attempting to access temporary manifest.json files.

| Issue | Component | Severity | Root Cause |
|-------|-----------|----------|------------|
| 1 | Canary model loading | **Critical** | Invalid/truncated git revision hash |
| 2 | Parakeet model loading | **Critical** | Windows temp file locking during NeMo extraction |

**Why bundled:** Both prevent core transcription functionality, both affect `transcribe_ui.py` model loading logic, and both require coordinated fixes to restore full application functionality.

<scope>
**Modify:**
- `transcribe_ui.py` (CANARY_PINNED_REVISION constant, lines ~29)
- `transcribe_ui.py` (load_model function error handling for Windows, lines ~257-350)

**Do NOT Modify:**
- `setup_local_models.py` (working correctly)
- Core NeMo framework code (external dependency)
- Model download/caching logic (functioning as designed)
</scope>

---

## Issue 1: Canary Model - Invalid Git Revision Hash

### Problem
User attempts to load Canary-Qwen-2.5B model and receives error: `"OSError: <revision_hash> is not a valid git identifier (branch name, tag name or commit id) that exists for this model name."`

### Root Cause

**File:** `transcribe_ui.py`  
**Location:** Line ~29 (CANARY_PINNED_REVISION constant)  
**Issue:** The hardcoded revision hash `"2399591399e4e6438fa7804f2f1f660"` is malformed - it contains only 31 characters when Git SHA-1 commit hashes require exactly 40 hexadecimal characters. This truncated hash is neither a valid full commit hash, nor a valid short hash (7-12 chars), nor a branch/tag name.

HuggingFace's `from_pretrained()` expects the `revision` parameter to be one of:
- Full SHA-1 hash (40 characters)
- Short commit hash (7-12 characters) 
- Branch name (e.g., "main")
- Tag name

The current 31-character value falls into none of these categories, causing HuggingFace to reject it as invalid.

**Valid commit hashes from nvidia/canary-qwen-2.5b repository:**
- Latest: `418c32c` (short) / `418c32c...` (full 40-char hash)
- Alternative: `a35ed36`, `6852529`, `45f41ac`

### Fix Required

Remove or correct the malformed revision hash in `CANARY_PINNED_REVISION`. Three approaches (in order of preference):

**Option A (Recommended):** Remove revision pinning entirely to use latest model
```python
CANARY_PINNED_REVISION = None  # Or omit from MODEL_CONFIGS["canary"]
```

**Option B:** Use branch name for stable updates
```python
CANARY_PINNED_REVISION = "main"
```

**Option C:** Use valid short commit hash if specific version needed
```python
CANARY_PINNED_REVISION = "418c32c"  # Latest as of Dec 2024
```

Avoid using incomplete hashes - either use full 40-char hashes or standardized short hashes (7-12 chars).

---

## Issue 2: Parakeet Model - Windows Temp File Locking

### Problem
User attempts to load Parakeet model and receives error: `"[WinError 32] The process cannot access the file because it is being used by another process: 'C:\Users\chunk\AppData\Local\Temp\tmp0SSjzum\manifest.json'"`. The error occurs during NeMo's internal `.nemo` file extraction process.

### Root Cause

**File:** NeMo framework internal (`nemo/core/connectors/save_restore_connector.py`)  
**Location:** `restore_from()` method's `TemporaryDirectory` context manager  
**Issue:** NeMo's model loading process extracts `.nemo` archives to temporary directories using Python's `tempfile.TemporaryDirectory()`. On Windows, file handles created during extraction (particularly manifest.json) are not properly closed before the context manager attempts cleanup. Windows enforces stricter file locking than Linux, preventing deletion of files with open handles. This causes the cleanup to fail with `PermissionError [WinError 32]`.

**The extraction flow:**
1. NeMo creates temporary directory: `C:\Users\...\Temp\tmp<random>\`
2. Extracts `.nemo` archive contents (tar.gz)
3. Reads `manifest.json` and other files
4. **Problem:** File handles remain open
5. Context manager tries to delete temp directory
6. **Windows blocks deletion** due to locked files

This is a known limitation of `TemporaryDirectory` on Windows when working with multiple file operations - the Python documentation notes that file handles must be explicitly closed before cleanup can succeed on Windows.

### Fix Required

The root issue is in NeMo's framework code (external dependency), but can be worked around in `transcribe_ui.py`. Add Windows-specific error handling to gracefully handle temp file cleanup failures.

**In `load_model()` function:**

Add try-except wrapper around model loading that handles Windows permission errors gracefully. The model may still load successfully even if temp cleanup fails - NeMo completes extraction before cleanup runs.

**Pattern to follow:**
```python
# Wrap ASRModel.restore_from() calls with Windows-aware error handling
# Log but don't fail on temp cleanup errors (model already loaded)
# Reference: Python tempfile docs note cleanup may fail on Windows
```

**Alternative approach (if above insufficient):**

Check if environment variables `TEMP` or `TMP` point to locations being monitored by:
- Antivirus software (particularly Windows Defender)
- Cloud sync services (OneDrive, Dropbox, Google Drive)
- Backup software

These can lock files in temp directories, causing NeMo's cleanup to fail. Recommend documenting requirement to exclude temp directory from real-time scanning/syncing.

**Note:** The underlying NeMo issue may be resolved in future framework versions by using `TemporaryDirectory(ignore_cleanup_errors=True)` or implementing Windows-compatible file handle management.

---

## Shared Implementation Notes

- Canary fix requires only constant value change - no architectural changes
- Parakeet workaround should **not** suppress legitimate model loading errors, only temp cleanup failures
- Both fixes are in `transcribe_ui.py` - no modifications needed to `setup_local_models.py`
- Test both models after fixes to verify independent operation
- Consider adding user-facing error messages distinguishing between "model failed to load" vs "model loaded but temp cleanup failed"

<acceptance_criteria>

**Issue 1 (Canary):**
- Canary model loads successfully from HuggingFace
- No "invalid git identifier" errors appear
- Model caches correctly for offline use
- First load downloads ~5GB, subsequent loads instant

**Issue 2 (Parakeet):**  
- Parakeet model loads from local `.nemo` file
- Script handles Windows temp file cleanup gracefully
- Transcription proceeds normally even if cleanup fails
- Appropriate logging indicates any cleanup issues without failing load

**All Issues:**
- Both models can be loaded and used for transcription
- No changes break existing functionality
- Error messages clearly distinguish between load failures and cleanup issues
- Manual test: Load each model, transcribe sample audio, verify results

</acceptance_criteria>

## Supporting Context

<details>
<summary>Issue 1: Git Hash Validation Evidence</summary>

**Git commit hash specifications:**
- SHA-1 hashes are always exactly 40 hexadecimal characters
- Short hashes are typically 7-12 characters (repo-dependent)
- Git will reject hashes that don't match these patterns

**HuggingFace validation:**
HuggingFace's model loading validates revision identifiers against the repository's git history. The error message "not a valid git identifier" indicates the provided string doesn't match any:
- Commit hash (full or short)
- Branch name  
- Tag name

**Current malformed value analysis:**
```python
CANARY_PINNED_REVISION = "2399591399e4e6438fa7804f2f1f660"
# Length: 31 characters
# Status: Invalid (too short for full hash, too long for short hash)
# Format: Hexadecimal (valid format, wrong length)
```

**Valid alternatives from repository:**
```
418c32c (latest commit - short hash, 7 chars)
a35ed36 (earlier commit - short hash, 7 chars)  
main (branch name - always latest)
```

</details>

<details>
<summary>Issue 2: Windows File Locking Context</summary>

**Windows vs Linux file locking differences:**
- **Linux:** Files can be deleted while open; deletion deferred until handles closed
- **Windows:** Files cannot be deleted while any handle is open; deletion fails immediately with `WinError 32`

**NeMo's extraction process (from source code analysis):**
```python
with tempfile.TemporaryDirectory() as tmpdir:
    try:
        self._unpack_nemo_file(path2file=restore_path, out_folder=tmpdir)
        os.chdir(tmpdir)
        # Load model components from extracted files
        # ** File handles may still be open here **
    finally:
        os.chdir(cwd)
# ** Context manager tries to cleanup tmpdir **
# ** Windows blocks if files still locked **
```

**Python tempfile documentation note:**
> "On Windows, the directory is not automatically cleaned up if the files are still open. This is a known limitation of the Windows API."

**Common Windows locking causes:**
1. Antivirus real-time scanning (locks files being scanned)
2. Cloud sync services (OneDrive, Dropbox) monitoring temp folders  
3. File indexing services
4. Backup software
5. File handles not explicitly closed in code

**Recommended workarounds:**
- Use `TemporaryDirectory(ignore_cleanup_errors=True)` (Python 3.10+)
- Manually close file handles before context exit
- Set `TEMP` environment variable to non-monitored location
- Exclude temp folder from antivirus scanning

</details>

<details>
<summary>NeMo Documentation References</summary>

**`restore_from()` method signature:**
```python
ASRModel.restore_from(
    restore_path: str,
    override_config_path: Optional[str] = None,
    map_location: Optional[torch.device] = None,
    strict: bool = True,
    return_config: bool = False,
    trainer: Optional[Trainer] = None,
    validate_access_integrity: bool = True
)
```

**Key parameters:**
- `restore_path`: Path to `.nemo` file
- No direct parameter to control temp directory behavior
- Cleanup is handled internally by `SaveRestoreConnector`

**Alternative loading approach (if temp issues persist):**

NeMo supports loading from pre-extracted directory using internal `model_extracted_dir` parameter (not directly accessible in public API). Manual extraction as workaround:
1. Extract `.nemo` (tar.gz archive) to permanent directory
2. Point `restore_path` to extracted directory instead of `.nemo` file
3. Bypasses temporary directory creation entirely

However, this approach requires modifying NeMo's internal behavior and is not recommended for user-facing fixes.

</details>

---

**Priority:** Critical (both issues block core functionality)  
**Target:** Fix both in single PR  
**Estimated Complexity:** Low (Issue 1) + Medium (Issue 2) = Medium overall
