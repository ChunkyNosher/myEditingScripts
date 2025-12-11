# CRITICAL REVISION: The Real Issue is NOT Just the API Parameter

## URGENT CORRECTION

**My previous diagnosis was INCOMPLETE.** While removing the `batch_size` parameter is correct, there's a MUCH DEEPER issue revealed by the manifest.json file you provided.

---

## What the manifest.json Tells Us

The manifest.json file you attached shows:

```json
{
  "audio_filepath": "E:\\Chunky's Master Folder\\myEditingScripts\\model_cache\\tmp\\gradio\\...",
  "duration": 100000,
  "text": ""
}
```

**This file exists because:** NeMo's `transcribe()` method **INTERNALLY CREATES** manifest files for inference processing. Even the simple inference API uses manifest files behind the scenes for batch processing.

**The real error message was:**
```
[WinError 32] The process cannot access the file because it is being used by another process: 
"E:\Chunky's Master Folder\myEditingScripts\model_cache\tmp\tmpf7hgl9wq\manifest.json"
```

This is **NOT an API parameter error at all.** This is a **file locking issue during NeMo's internal manifest creation/processing**, which reveals the true root cause is still the Windows temp directory problem.

---

## The REAL Root Cause: NeMo Inference Uses Temporary Manifest Files

**What's actually happening:**

1. Your code calls `model.transcribe(processed_files, timestamps=True)`
2. NeMo internally converts the file list to a temporary manifest JSON file
3. NeMo tries to load/process this manifest file
4. **Windows antivirus/OneDrive locks the manifest.json file while NeMo tries to read it**
5. `WinError 32` occurs - file is in use by antivirus scanning

**This is still the Windows file locking issue, but at a DIFFERENT layer than before.**

Before, the file lock happened during `.nemo` archive extraction (`model_weights.ckpt`).

Now, even though you've set `tempfile.tempdir`, the manifest.json **created by NeMo during inference** is being locked by Windows services in the temp directory.

---

## Why This is Happening

The `transcribe_ui.py` file configuration (lines 1-68) correctly sets:
```python
os.environ["TMPDIR"] = str(_cache_dir / "tmp")
os.environ["TEMP"] = str(_cache_dir / "tmp")
os.environ["TMP"] = str(_cache_dir / "tmp")
tempfile.tempdir = str(_temp_dir)
```

**BUT**, from the error path, the manifest.json is being created in:
```
model_cache/tmp/gradio/40551d8919f36e2dbeddbdadea2843c3077303a86f3d192b0b07043c2a0cda4b/
```

This suggests Gradio is creating a **separate temp subdirectory** (`gradio/`) for uploaded files, and NeMo's internal manifest creation might be using that location or a system temp location that's NOT respecting your `tempfile.tempdir` override.

**Two possibilities:**

1. **NeMo's manifest creation happens BEFORE respecting tempfile.tempdir** - NeMo module initialization caches the system temp location before your environment variable setup
2. **Gradio's temp file handling is creating files in system %TEMP%** - The uploaded audio files are in Gradio's temp location, and NeMo creates manifest.json in the same location

---

## The Real Fixes Needed

### Fix #1: Remove `batch_size` Parameter (STILL REQUIRED)

This must be done regardless - it's not the root cause but it IS an API error that needs fixing.

### Fix #2: Ensure NeMo Manifest Creation Uses Custom Temp Directory

The manifest.json file needs to be created in your controlled cache directory, not system temp.

**Two approaches:**

**Approach A: Force NeMo to use extracted manifest (BEST)**
- Pre-create manifest files in cache directory
- Pass manifest path explicitly to NeMo
- Completely avoid temp directory for manifest files

**Approach B: Set tempfile.tempdir EARLIER and MORE AGGRESSIVELY**
- Ensure ABSOLUTELY NO NeMo imports happen before tempfile.tempdir is set
- Move ALL NeMo imports to AFTER the tempfile configuration
- Add explicit validation that `tempfile.gettempdir()` returns your custom path
- Force re-initialization of any NeMo internals that might have cached the temp path

### Fix #3: Handle Gradio's Temp Files

Gradio uploads files to its own temp directory. When NeMo reads these files, it might create manifest.json in that location or in system temp.

**Solution:**
- Copy/move uploaded files from Gradio temp to your controlled cache directory BEFORE passing to NeMo
- Or configure Gradio to use your cache directory for temp files

---

## Why This Reveals a Deeper Architectural Issue

The problem is that:
1. You fixed the NeMo model extraction temp file issue (WinError 32 for model_weights.ckpt)
2. But NeMo has MULTIPLE points where it uses temp files:
   - Model extraction (.nemo archive unpacking)
   - **Manifest file creation during inference** ← Current failure point
   - Potentially other internal operations

Each of these can independently hit file locking errors because they all try to use system %TEMP% or your configured temp location, which Windows services are monitoring.

---

## The Systemic Solution

Rather than patching each individual temp file location, implement a comprehensive approach:

1. **Ensure ABSOLUTE EARLIEST tempfile.tempdir configuration**
   - Move tempfile configuration to absolute beginning of script
   - Before ANY other imports except os/sys/pathlib
   - Validate configuration worked

2. **Force Manifest File Creation in Controlled Location**
   - Pre-create manifest files in cache directory
   - Pass manifest_filepath explicitly to NeMo's transcribe()
   - Don't rely on NeMo's internal temporary manifest creation

3. **Copy Gradio Uploads to Safe Location**
   - When Gradio provides uploaded files, copy them to your cache directory immediately
   - Pass cached copy paths to NeMo, not Gradio's temp paths
   - This prevents NeMo from creating manifests in Gradio's temp location

4. **Add Comprehensive File Locking Retry Logic**
   - Every operation that touches files should have retry logic
   - Include exponential backoff (0.5s, 1s, 1.5s, 2s)
   - Graceful degradation if retries exhaust

---

## Expected Implementation Impact

After implementing these fixes:
1. ✅ All NeMo operations use your cache directory, not system %TEMP%
2. ✅ Gradio uploaded files are copied to controlled location
3. ✅ NeMo manifest files are created in cache, not system temp
4. ✅ Retry logic handles any transient Windows file locks
5. ✅ Inference proceeds without permission errors

---

## Summary of Changes Needed

**You were right to question the API parameter error diagnosis.** While the `batch_size` parameter does need to be removed, the **ACTUAL failure point is file locking on manifest.json during inference**, which reveals NeMo uses temporary manifest files throughout the inference pipeline.

The fix requires:
1. Removing `batch_size` parameter (API fix)
2. Pre-creating and managing manifest files in cache directory (architectural fix)
3. Handling Gradio's temp files properly (integration fix)
4. Comprehensive retry logic for file operations (robustness fix)