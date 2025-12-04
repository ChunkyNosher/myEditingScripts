# Local Model Storage: Fix HuggingFace Cache Re-Download Issue

**Script:** transcribe_ui.py | **Date:** 2025-12-04 | **Issue:** Infinite model re-download loop due to HuggingFace revision hash changes

---

## Problem Summary

NeMo's `from_pretrained()` method checks HuggingFace for the latest model revision on every run. When the HuggingFace repository updates (even minor changes), the expected cache directory hash changes, causing NeMo to delete the existing 5.12GB download and re-download from scratch. This creates an infinite loop where models never stay cached.

## Root Cause

**File:** `transcribe_ui.py`  
**Location:** `load_model()` function (lines 14-26)  
**Issue:** The function uses `from_pretrained("nvidia/canary-qwen-2.5b")` which queries HuggingFace for the "latest" revision without pinning to a specific commit hash. When HuggingFace model repo updates, the revision hash changes from `2399591399e4e6438fa7804f2f1f1660` to `1299591399eded3876a0e42f1f1660`, causing NeMo to treat cached files as invalid and delete them. The solution is to download models once using `from_pretrained()`, save them as local .nemo files using `save_to()`, then load from local files using `restore_from()` to completely bypass HuggingFace lookups.

<scope>
**Modify:**
- `transcribe_ui.py` (load_model function, startup validation, UI documentation)
- Create `local_models/` directory structure
- Add model existence validation before loading

**Do NOT Modify:**
- NeMo library internals
- HuggingFace cache system  
- Python models_cache dictionary (working correctly for in-memory caching)
- Transcription logic in transcribe_audio()
</scope>

---

## Fix Required

### Change 1: Replace from_pretrained() with restore_from()

**Problem:** Current load_model() function downloads from HuggingFace on every run, subject to revision hash changes.

**Fix Required:**
Modify load_model() function to use restore_from() method with local .nemo file paths instead of from_pretrained() with HuggingFace model names. The .nemo files will be created by user in separate setup step (see user guide). Function should check if .nemo files exist before attempting to load, and provide clear error message if files missing.

**Current implementation:**
```python
def load_model(model_name):
    if model_name not in models_cache:
        print(f"Loading {model_name} model...")
        if model_name == "parakeet":
            models_cache[model_name] = nemo_asr.models.ASRModel.from_pretrained(
                "nvidia/parakeet-tdt-0.6b-v2"
            )
        else:  # canary
            models_cache[model_name] = nemo_asr.models.ASRModel.from_pretrained(
                "nvidia/canary-qwen-2.5b"
            )
        print(f"✓ {model_name} loaded successfully")
    return models_cache[model_name]
```

**Expected behavior after fix:**
- Check if .nemo file exists at expected path (local_models/parakeet.nemo or local_models/canary.nemo)
- If file missing, raise clear FileNotFoundError with instructions to run setup script
- If file exists, use restore_from() to load from local file
- No HuggingFace lookups, no revision hash validation, complete offline operation
- Faster loading (no cache validation overhead)

### Change 2: Add Startup Model Validation

**Problem:** Script launches UI without checking if required .nemo files exist, causing failures on first transcription attempt with no user warning.

**Fix Required:**
Add validation function that runs before UI launches to check if local_models/ directory exists and contains both required .nemo files (parakeet.nemo and canary.nemo). If directory or files missing, print clear error message with instructions and exit gracefully before UI loads. This prevents confusing UX where UI appears to work but fails on first use.

**Implementation approach:**
Create new function validate_local_models() that checks file existence. Call this function in the `if __name__ == "__main__":` block BEFORE app.launch(). If validation fails, print error message with setup instructions and sys.exit(1).

**Expected behavior:**
- Runs automatically on script startup
- Checks for local_models/parakeet.nemo existence
- Checks for local_models/canary.nemo existence  
- If both exist: proceeds to launch UI normally
- If either missing: prints error message explaining setup requirement and exits before UI loads
- Error message should reference user setup guide and provide exact file paths needed

### Change 3: Update UI Documentation

**Problem:** Current UI text references model download delays and HuggingFace behavior that will no longer apply with local .nemo files.

**Fix Required:**
Update Gradio interface markdown text to reflect new local model approach. Remove references to "first run loads models (~20-30 seconds)" and "models cached in VRAM". Update "How to Use" section to mention models load from local files. Update "Privacy & Performance" section to emphasize completely offline operation after setup. Add note that models must be set up once using separate script.

**Sections to update:**
1. Main header: Update subtitle about model source
2. "How to Use" accordion: Remove model download references, add local file mention
3. "Privacy & Performance" accordion: Emphasize offline nature, remove cache discussion
4. Model Information section: Update loading behavior description

**Keep existing:**
- All transcription functionality descriptions
- Performance benchmarks
- Model accuracy specs
- GPU optimization details

### Change 4: Error Handling for Missing Models

**Problem:** If user runs script without creating .nemo files first, error messages will be cryptic FileNotFoundError from deep in NeMo library.

**Fix Required:**
Wrap restore_from() calls in try-except block to catch FileNotFoundError specifically. If caught, raise custom error message explaining that .nemo files must be created using setup script, with exact file paths that are missing. This provides actionable guidance instead of raw Python traceback.

**Expected behavior:**
- Catch FileNotFoundError from restore_from()
- Check which specific .nemo file is missing
- Raise clear exception with setup instructions
- Include exact path that was attempted
- Reference user setup guide document

---

## Implementation Notes

**Local Model Directory Structure:**
```
myEditingScripts/
├── transcribe_ui.py
└── local_models/
    ├── parakeet.nemo  (created by user via setup script)
    └── canary.nemo    (created by user via setup script)
```

**NeMo .nemo File Format:**
- .nemo files are tar.gz archives containing model weights (model_weights.ckpt) and configuration (model_config.yaml)
- Created using model.save_to("path/to/model.nemo")
- Loaded using ASRModel.restore_from("path/to/model.nemo")
- Self-contained with all dependencies (tokenizers, vocab files, etc.)
- Portable across systems with same NeMo version

**restore_from() vs from_pretrained():**
- restore_from() loads from local .nemo file path, never contacts HuggingFace
- from_pretrained() queries HuggingFace for latest revision, downloads if needed
- restore_from() is faster (no validation overhead)
- restore_from() works completely offline
- Both return identical model objects for inference

**Validation Timing:**
- Startup validation prevents UI from loading if models missing
- Runtime validation in load_model() catches edge cases where files deleted during session
- Both validations should check same paths and provide same error messaging

<acceptance_criteria>
**Model Loading:**
- [ ] load_model() uses restore_from() instead of from_pretrained()
- [ ] Loads from local_models/parakeet.nemo for Parakeet
- [ ] Loads from local_models/canary.nemo for Canary
- [ ] No HuggingFace API calls during model loading
- [ ] Works completely offline after .nemo files created

**Startup Validation:**
- [ ] validate_local_models() function exists and runs before UI launch
- [ ] Checks for local_models/ directory existence
- [ ] Checks for both .nemo files existence
- [ ] Exits gracefully with clear error if files missing
- [ ] Error message includes setup instructions

**Error Handling:**
- [ ] FileNotFoundError caught and wrapped in custom message
- [ ] Error message explains setup requirement
- [ ] Error message includes exact missing file path
- [ ] References user setup guide for instructions

**UI Updates:**
- [ ] Header text updated to reflect local model source
- [ ] "How to Use" section removes HuggingFace download references
- [ ] "Privacy & Performance" section emphasizes offline operation
- [ ] Model Information section accurate for local loading

**Functionality:**
- [ ] All existing transcription features work unchanged
- [ ] Performance statistics remain accurate
- [ ] GPU utilization unaffected
- [ ] No regressions in transcription quality or speed
- [ ] Manual test: transcribe audio with local models → works identically to before
</acceptance_criteria>

---

## Supporting Context

<details>
<summary>NeMo save_to() and restore_from() Documentation</summary>

**Official NeMo Documentation:**
From NVIDIA NeMo Framework User Guide:

```python
# Save a model to .nemo file
model.save_to('/path/to/model.nemo')

# Restore model from .nemo file
model = nemo_asr.models.ASRModel.restore_from('/path/to/model.nemo')
```

**What's in a .nemo file:**
- model_config.yaml - Model configuration in YAML format
- model_weights.ckpt - Model checkpoint (PyTorch state dict)
- All artifacts (tokenizers, vocabulary files, etc.)
- Self-contained archive (tar.gz format)

**Benefits:**
- No external dependencies after creation
- Portable across systems (same NeMo version)
- Faster loading (no validation overhead)
- Completely offline operation
- Immune to HuggingFace repo updates

**Compatibility:**
- Works with ASRModel base class (confirmed)
- Compatible with all NeMo ASR model types
- No version issues found in research
- Standard practice in NeMo ecosystem
</details>

<details>
<summary>Why from_pretrained() Causes Re-Downloads</summary>

**from_pretrained() Default Behavior:**
```python
# This ALWAYS checks HuggingFace for latest revision
model = ASRModel.from_pretrained("nvidia/canary-qwen-2.5b")
# Equivalent to: revision="main" (latest commit on main branch)
```

**What happens each time:**
1. Query HuggingFace API for current HEAD of main branch
2. Get commit hash (e.g., `2399591399...`)
3. Check if cache directory with that hash exists
4. If hash different from cached: DELETE cache, RE-DOWNLOAD
5. If hash matches: Use cache

**Why hash changes:**
- HuggingFace repos updated frequently (README edits, metadata changes)
- Each commit generates new hash
- New hash = new expected cache directory
- Old cache treated as "outdated" even if model weights identical

**Evidence from console:**
- First download: `...2399591399e4e6438fa7804f2f1f1660`
- Second run: `...1299591399eded3876a0e42f1f1660`
- Different hashes = NeMo deletes first, downloads second
- Infinite loop if repo keeps updating

**Solution:**
restore_from() bypasses all HuggingFace lookups. Loads directly from file. No hash validation. No revision checking. Just load and go.
</details>

<details>
<summary>Directory Structure and File Paths</summary>

**Expected paths (relative to transcribe_ui.py):**
```
./local_models/parakeet.nemo
./local_models/canary.nemo
```

**Validation checks:**
```python
import os

# Check directory exists
assert os.path.exists("local_models"), "local_models/ directory not found"

# Check Parakeet exists
assert os.path.exists("local_models/parakeet.nemo"), "parakeet.nemo not found"

# Check Canary exists  
assert os.path.exists("local_models/canary.nemo"), "canary.nemo not found"
```

**Error message template:**
```
❌ Local models not found!

Required files:
  • local_models/parakeet.nemo
  • local_models/canary.nemo

These files must be created once using the setup script.
Please run: python setup_local_models.py

See user-model-setup-guide.md for instructions.
```
</details>

<details>
<summary>Performance Comparison</summary>

**from_pretrained() (current):**
- Check HuggingFace API: ~500ms
- Validate cache structure: ~200ms
- Load model weights: ~2-3s
- Total: ~3-4s per model

**restore_from() (after fix):**
- Load model weights: ~2-3s
- Total: ~2-3s per model

**Savings:** ~1-1.5s per model load, plus elimination of re-download risk

**Other benefits:**
- No internet required
- No cache validation failures
- Predictable behavior
- Professional production-ready approach
</details>

---

**Priority:** Critical (blocks all usage, infinite re-download loop)  
**Impact:** Permanent fix for cache invalidation issue  
**Complexity:** Low-Medium (straightforward API swap, needs validation)  
**Estimated Time:** 15-30 minutes for Copilot implementation
