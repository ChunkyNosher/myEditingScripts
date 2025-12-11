# Diagnostic Report: NeMo Model Loading PermissionError on Windows

## Issue Summary

After disabling the Gradio queue (`queue=False`), the transcription process now attempts to start but immediately fails with:

```
PermissionError: [WinError 32] The process cannot access the file because it is being used by another process: 'E:\Chunky\Master Folder\yEditingScripts\model_cache\tmp\tmpgdU\...\model_weights.ckpt'
```

The error occurs during `ASRModel.restore_from()` when NeMo attempts to extract the `.nemo` model archive. This is a **Windows-specific file locking issue** that wasn't visible before because the queue system deadlock masked it.

---

## Root Cause Analysis

### The Problem: NeMo Model Extraction Uses Windows TEMP Directory

When you call `ASRModel.restore_from(local_path)` or `ASRModel.from_pretrained(hf_model_id)`, NeMo's save/restore connector performs these steps:

1. **Creates a TemporaryDirectory** (from Python's `tempfile` module)
2. **Extracts the .nemo tar archive** into that temp directory
3. **Loads model weights** from extracted files
4. **Cleans up** the temporary directory

**The Issue**: On Windows, the temporary directory extraction uses the system's `TMPDIR` environment variable, which defaults to `C:\Users\<username>\AppData\Local\Temp` (Windows temp folder).

#### Why This Causes File Locks

Windows services monitor the `%TEMP%` directory:
- **Windows Defender/Antivirus**: Scans files as they're extracted
- **OneDrive/Google Drive/Dropbox**: Sync services monitor temp files
- **Windows Search/Indexing Service**: Keeps file handles open for indexing
- **File Explorer Explorer Context Menus**: Can hold file handles

When NeMo tries to load weights from extracted files, these services have **exclusive locks** on the files, causing `WinError 32` ("file in use by another process").

### Evidence from NeMo Source Code

From the [NeMo save_restore_connector.py](https://github.com/NVIDIA/NeMo/blob/main/nemo/core/connectors/save_restore_connector.py):

```python
with tempfile.TemporaryDirectory() as tmpdir:
    try:
        # ...
        self._unpack_nemo_file(path2file=restore_path, out_folder=tmpdir, members=members)
        
        # Now loads weights from tmpdir
        model_weights = os.path.join(tmpdir, self.model_weights_ckpt)
        # ← File lock happens here if tmpdir is on Windows %TEMP%
```

**The critical line**: `with tempfile.TemporaryDirectory() as tmpdir:` uses the default temp directory without respecting custom `TMPDIR` settings **if they're set after imports**.

### Why Your Environment Variable Fix Didn't Fully Work

In `transcribe_ui.py`, lines 1-43, you set:

```python
os.environ["TMPDIR"] = str(_cache_dir / "tmp")
os.environ["TEMP"] = str(_cache_dir / "tmp")
os.environ["TMP"] = str(_cache_dir / "tmp")
```

**This works for most libraries**, but **NeMo's save_restore_connector.py has a critical flaw**:

The `tempfile.TemporaryDirectory()` call happens **inside the restore process**, and on Windows, `tempfile` can be **stubborn about respecting environment variables** set in the same Python process if the `tempfile` module was already imported with different settings.

Additionally, **the timing matters**: If NeMo was imported before you set `TMPDIR`, the module-level initialization of Python's `tempfile` internals may have already cached the system temp path.

---

## Why This Error Appears Now (But Not Before)

1. **With `queue=True`**: The Gradio queue deadlock occurred **before** NeMo could extract the model, masking this file lock issue
2. **With `queue=False`**: The inference actually attempts to run, and NeMo immediately hits the file lock when extracting the `.nemo` archive

The file lock was always there—you just didn't get far enough to see it until the queue was disabled.

---

## Required Fixes

### 1. Use Pre-Extracted Models (Primary Fix - Most Robust)

The most reliable solution is to use `restore_from()` with pre-extracted `.nemo` files in your `local_models/` directory (which avoids the temp extraction entirely):

**Current problematic path:**
- `ASRModel.restore_from()` → extracts tar → temp file locks → WinError 32

**Better path:**
- Ensure `.nemo` files exist locally (via `setup_local_models.py`)
- Call `ASRModel.restore_from(str(model_path))` with local `.nemo` files
- This still extracts to temp but avoids repeated downloads

**Best path:**
- Use the `model_extracted_dir` parameter in NeMo's restore_from method
- Pre-extract `.nemo` files to a persistent directory
- Load directly from extracted files (no temp extraction needed)

This completely bypasses the `tempfile.TemporaryDirectory()` issue because NeMo checks for `model_extracted_dir` first and skips the temp directory entirely:

```python
if self.model_extracted_dir is not None and os.path.isdir(self.model_extracted_dir):
    tmpdir = self.model_extracted_dir  # ← Use this instead of temp
```

### 2. Force Early TMPDIR Configuration (Secondary Fix)

Move the TMPDIR configuration to happen **before ANY imports** of PyTorch/NeMo:

**Current location**: Lines 1-43 of `transcribe_ui.py` ✅ (already correct position)

However, add an additional safety measure by explicitly calling `tempfile.gettempdir()` **after** setting environment variables to force `tempfile` to re-read them:

```python
import tempfile
import tempfile._get_default_tempdir  # Force module refresh

os.environ["TMPDIR"] = str(_cache_dir / "tmp")
os.environ["TEMP"] = str(_cache_dir / "tmp")
os.environ["TMP"] = str(_cache_dir / "tmp")

# Force tempfile to recalculate temp directory
tempfile.tempdir = str(_cache_dir / "tmp")  # ← Explicitly set
```

### 3. Implement Retry Logic with Exclusions (Tertiary Fix)

Add antivirus/cloud-sync exclusions for the cache directory path to prevent Windows services from locking extracted files:

```python
# Document this for user setup:
# 1. Add C:\Users\<username>\.chunky\model_cache to Windows Defender exclusions
# 2. Exclude model_cache folder from OneDrive/Dropbox/Google Drive sync
# 3. Disable Windows Search indexing for model_cache folder
```

### 4. Implement Async File Locking Retry (Quaternary Fix - If Fixes 1-3 Insufficient)

Wrap the `restore_from()` call with exponential backoff retry logic that specifically handles `WinError 32`:

- Detect `PermissionError` with "WinError 32" in the message
- Wait 0.5s, then 1s, then 2s between retries (exponential backoff)
- Force garbage collection between retries to release file handles
- Call `torch.cuda.empty_cache()` to clear GPU memory locks
- Retry up to 5 times before raising error

This gives antivirus/sync services time to release file handles.

---

## Recommended Implementation Priority

**For immediate fix (best approach):**
1. Implement Fix #1 (model_extracted_dir parameter) - most robust, avoids temp entirely
2. Ensure `setup_local_models.py` creates `.nemo` files in `local_models/`
3. Update `load_model()` function to pre-extract models to persistent cache on first use

**For robustness (if Fix #1 insufficient):**
1. Add Fix #2 (explicit tempfile.tempdir setting)
2. Add Fix #4 (retry logic with backoff)
3. Document Fix #3 (user antivirus/sync exclusions) in setup guide

---

## Technical Details

### Windows Temp Directory Monitoring

According to Microsoft Security and StackOverflow discussions:
- Windows Defender scans temp files at extraction time
- OneDrive/Google Drive monitor for changes continuously
- These locks are **unpredictable** (depends on antivirus scan speed)
- The same operation can succeed/fail on different runs

### NeMo Architecture

From NeMo source code analysis:
- `.nemo` files are tar.gz archives
- `restore_from()` → `save_restore_connector.py` → `_unpack_nemo_file()`
- `_unpack_nemo_file()` uses `tarfile.open()` to extract
- Extraction happens to `tempfile.TemporaryDirectory()` by default
- Model loading immediately follows extraction

### Why File Locks Happen

The sequence:
1. Extract `model_weights.ckpt` to temp directory
2. Antivirus scans file as it's written
3. NeMo tries to load the file
4. Windows returns `WinError 32` because antivirus still has file handle

---

## Validation Strategy

To confirm the diagnosis:

1. **Test with pre-extracted models**: If you use models already in `model_extracted_dir`, this error won't occur
2. **Check Windows Event Viewer**: Look for antivirus/defender activity at error time
3. **Disable antivirus temporarily**: If error disappears, confirms antivirus is locking files
4. **Test with different cache location**: Use a local non-sync folder (not OneDrive/Dropbox)

---

## Summary

The `PermissionError: WinError 32` occurs because **NeMo's model loading extracts archives to the Windows TEMP directory, which is monitored by antivirus, cloud sync, and search services that hold exclusive file locks**. 

The queue system previously masked this issue by deadlocking before extraction occurred.

**Best solution**: Implement `model_extracted_dir` parameter to completely bypass temporary directory extraction, or ensure TMPDIR points to a location not monitored by Windows security services. Add retry logic with exponential backoff as a fallback for stubborn file locks.