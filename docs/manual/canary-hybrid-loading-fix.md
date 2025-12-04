# Hybrid Model Loading: Parakeet Local + Canary Direct

**Issue:** Canary-Qwen-2.5B cannot be saved as .nemo file due to SALM model architecture incompatibility  
**Solution:** Use local .nemo for Parakeet, direct HuggingFace loading with pinned revision for Canary

---

## Root Cause Identified

Canary-Qwen-2.5B is a **SALM (Speech-Aware Language Model)** that HuggingFace hosts as raw model files (safetensors format), not as a pre-packaged .nemo archive. NeMo's `save_to()` method expects to find `model_config.yaml` in the cache during the save process, but this file doesn't exist in the HuggingFace repository structure for Canary.

**This is NOT:**
- ❌ Cache corruption (cache clearing didn't fix it)
- ❌ Network issue (download completes successfully)  
- ❌ Windows path issue (Parakeet works fine on same system)
- ❌ Disk space issue (5.12GB successfully downloaded)

**This IS:**
- ✅ Model architecture incompatibility between SALM models and NeMo's standard save_to() workflow
- ✅ HuggingFace repo structure difference (raw files vs. pre-packaged .nemo)
- ✅ Known limitation of newer SALM model types

---

## Problem Summary

**File:** `transcribe_ui.py`  
**Location:** `load_model()` function  

**Current Broken Approach:**
Both models try to load from local .nemo files → Canary .nemo creation fails → infinite re-download loop

**Working Solution:**
- **Parakeet:** Load from local .nemo file (already working)
- **Canary:** Load directly from HuggingFace with pinned revision (prevents re-downloads)

<scope>
**Modify:**
- `transcribe_ui.py` (load_model function to handle two different loading methods)
- Add revision pinning for Canary

**Do NOT Modify:**
- Parakeet loading (already works perfectly with local .nemo)
- Transcription logic
- UI interface
- GPU optimizations
</scope>

---

## Fix Required

### Change 1: Modify load_model() for Hybrid Approach

**Problem:** Current implementation tries to load both models the same way (from local .nemo files). Canary cannot be packaged as .nemo due to SALM architecture.

**Fix Required:**
Update load_model() function to use two different loading methods:
1. **Parakeet:** restore_from() with local .nemo file (keep as-is)
2. **Canary:** from_pretrained() with pinned revision to prevent re-downloads

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
- Parakeet: Loads from local_models/parakeet.nemo using restore_from()
- Canary: Loads from HuggingFace cache using SALM.from_pretrained() with revision pinned to "2399591399e4e6438fa7804f2f1f1660"
- Canary downloads once to cache, then loads from cache on subsequent runs (no re-downloads)
- Both models cached in memory after first load

**Implementation requirements:**
- Import SALM model class for Canary loading
- Use restore_from() for Parakeet with local .nemo path
- Use SALM.from_pretrained() for Canary with revision parameter
- Add validation that parakeet.nemo exists before loading
- Document why Canary uses different approach (SALM architecture limitation)

### Change 2: Update Import Statements

**Problem:** Current code imports only ASRModel, but Canary requires SALM class.

**Fix Required:**
Add import for SALM model class at top of file. This is required because Canary-Qwen-2.5B is a Speech-Aware Language Model, not a standard ASR model.

**Expected additions:**
```python
from nemo.collections.speechlm2.models import SALM
```

### Change 3: Update Startup Validation

**Problem:** Current startup validation (if implemented) checks for both .nemo files, but Canary won't have a .nemo file.

**Fix Required:**
Modify validate_local_models() function (if exists) to only check for parakeet.nemo existence. Remove check for canary.nemo. Add informational message that Canary loads from HuggingFace cache with pinned revision.

**Expected behavior:**
- Checks only for local_models/parakeet.nemo
- If missing: exits with error and setup instructions
- If present: proceeds with launch
- Displays info that Canary will load from HuggingFace cache on first use

### Change 4: Update UI Documentation

**Problem:** Current UI text may reference both models loading from local files.

**Fix Required:**
Update Gradio interface markdown to reflect hybrid approach:
- Parakeet loads from local .nemo file (instant, offline)
- Canary loads from HuggingFace cache (first run downloads, subsequent runs use cache)
- Both models stay in memory after first load
- Note that Canary's architecture doesn't support .nemo packaging

**Sections to update:**
- "How to Use" accordion
- "Privacy & Performance" section
- Model information descriptions

### Change 5: Add Error Handling for Canary Cache

**Problem:** If HuggingFace cache is cleared, Canary will need to re-download.

**Fix Required:**
Add try-except around Canary loading to catch download failures. Provide clear error message if download fails (network issue, disk space, etc.). Message should explain that Canary requires internet connection on first load but works offline after cache populated.

**Expected error handling:**
- Catch exceptions from SALM.from_pretrained()
- Check if due to network (ConnectionError, HTTPError)
- Check if due to disk space (OSError)
- Provide actionable error message
- Suggest troubleshooting steps

---

## Implementation Notes

**Revision Pinning for Canary:**
The revision hash "2399591399e4e6438fa7804f2f1f1660" is the current version as of December 2025. This hash prevents the re-download loop by telling NeMo to always use this specific version, regardless of future updates to the HuggingFace repo.

**Why Two Different Approaches:**
- **Parakeet:** Uses traditional EncDecHybridRNNTCTCBPEModel architecture that supports .nemo packaging
- **Canary:** Uses newer SALM architecture that HuggingFace hosts as raw safetensors files, incompatible with .nemo packaging workflow

**Cache Behavior:**
- **Parakeet:** Loads from local_models/parakeet.nemo (never touches HuggingFace)
- **Canary:** First run downloads to C:\Users\chunk\.cache\torch\NeMo\..., subsequent runs load from cache

**Memory Caching:**
Both models use models_cache dictionary to stay in memory after first load, so loading only happens once per session regardless of approach.

**Performance Impact:**
- **Parakeet:** No change (already loading from local file)
- **Canary:** First load ~10-15 seconds (cache validation), subsequent loads ~3-5 seconds
- Both: Instant after first load in session (memory cache)

<acceptance_criteria>
**Model Loading:**
- [ ] Parakeet loads from local_models/parakeet.nemo using restore_from()
- [ ] Canary loads from HuggingFace using SALM.from_pretrained() with pinned revision
- [ ] Both models stay in memory cache after first load
- [ ] No re-downloads occur for Canary on subsequent runs
- [ ] Parakeet works completely offline
- [ ] Canary requires internet only on first load

**Imports:**
- [ ] SALM class imported from nemo.collections.speechlm2.models
- [ ] No import errors on startup

**Startup Validation:**
- [ ] Only checks for parakeet.nemo existence
- [ ] Exits gracefully if parakeet.nemo missing
- [ ] No check for canary.nemo
- [ ] Informational message about Canary's loading method

**Error Handling:**
- [ ] Canary loading wrapped in try-except
- [ ] Network errors caught and explained
- [ ] Disk space errors caught and explained
- [ ] Clear guidance for troubleshooting

**UI Updates:**
- [ ] Documentation reflects hybrid approach
- [ ] Parakeet described as local/offline
- [ ] Canary described as cached from HuggingFace
- [ ] SALM architecture limitation explained

**Functionality:**
- [ ] All transcription features work unchanged
- [ ] Parakeet performance same as before
- [ ] Canary performance acceptable (slight delay on first load)
- [ ] No regressions in quality or accuracy
- [ ] Manual test: transcribe with both models → both work correctly
</acceptance_criteria>

---

## Supporting Context

<details>
<summary>Evidence from Console Output</summary>

**Parakeet Success (Screenshot 2):**
```
[NeMo I] Model EncDecHybridRNNTCTCBPEModel was successfully restored from 
C:\Users\chunk\.cache\huggingface\hub\models--nvidia--parakeet-tdt-0.6b-v2\
snapshots\...\parakeet-tdt-0.6b-v2.nemo

✓ Parakeet saved successfully
✓ Verified: parakeet.nemo (2.38 GB)
```

**Canary Failure (Screenshot 1 & 2):**
```
FileNotFoundError: [Errno 2] No such file or directory: 
'C:\\Users\\chunk\\.cache\\torch\\NeMo\\NeMo_2.6.0\\hf_hub_cache\\nvidia\\
canary-qwen-2.5b\\2399591399e4e6438fa7804f2f1f1660\\model_config.yaml'
```

**Key Difference:**
- Parakeet cache contains complete .nemo file
- Canary cache contains individual files (model.safetensors, config.json, etc.) but NO model_config.yaml
- NeMo's save_to() can't package Canary's raw files into .nemo format
</details>

<details>
<summary>Model Architecture Differences</summary>

**Parakeet-TDT-0.6B v2:**
```python
# Traditional ASR model
from nemo.collections.asr.models import ASRModel
model = ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
model.save_to("parakeet.nemo")  # ✅ Works
```

**Canary-Qwen-2.5B:**
```python
# SALM (Speech-Aware Language Model)
from nemo.collections.speechlm2.models import SALM
model = SALM.from_pretrained("nvidia/canary-qwen-2.5b")
model.save_to("canary.nemo")  # ❌ Fails - model_config.yaml not found
```

**Why the difference:**
SALM models use a newer architecture that HuggingFace hosts differently. The from_pretrained() method for SALM constructs the model from raw files rather than extracting from a pre-packaged .nemo archive.
</details>

<details>
<summary>Revision Pinning Documentation</summary>

**from_pretrained() with revision parameter:**
```python
model = SALM.from_pretrained(
    "nvidia/canary-qwen-2.5b",
    revision="2399591399e4e6438fa7804f2f1f1660"  # Specific commit hash
)
```

**How it prevents re-downloads:**
1. First run: Downloads model files to cache at this revision
2. Subsequent runs: Finds exact revision in cache, skips download
3. Even if HuggingFace repo updates: Ignores updates, always uses pinned revision
4. Never re-downloads unless cache manually cleared

**Finding current revision:**
The hash "2399591399e4e6438fa7804f2f1f1660" appeared in both error messages, confirming this is the current version. This can be updated in the future if needed by checking HuggingFace repo commits.
</details>

<details>
<summary>Cache Location Details</summary>

**Parakeet Cache (Working):**
```
C:\Users\chunk\.cache\huggingface\hub\
└── models--nvidia--parakeet-tdt-0.6b-v2\
    └── snapshots\
        └── <hash>\
            └── parakeet-tdt-0.6b-v2.nemo  ← Complete archive
```

**Canary Cache (Different Structure):**
```
C:\Users\chunk\.cache\torch\NeMo\NeMo_2.6.0\hf_hub_cache\
└── nvidia\
    └── canary-qwen-2.5b\
        └── 2399591399e4e6438fa7804f2f1f1660\
            ├── model.safetensors  (5.12GB)
            ├── config.json
            ├── .gitattributes
            ├── LICENSES
            ├── README.md
            └── model_config.yaml  ← Doesn't exist!
```

**Why structure differs:**
- Parakeet: HuggingFace hosts pre-built .nemo file
- Canary: HuggingFace hosts raw PyTorch model weights
- NeMo handles these differently during from_pretrained()
</details>

---

## User Setup Steps

### Step 1: Complete Parakeet Setup (ONLY)

Run the corrected setup script ONLY for Parakeet:

**Modified setup_local_models.py (Parakeet only):**
```python
#!/usr/bin/env python3
import nemo.collections.asr as nemo_asr
import os
import sys

def download_and_save_parakeet():
    """Download Parakeet model and save as .nemo file."""
    print("\\n📦 Downloading Parakeet-TDT-0.6B v2...")
    
    try:
        model = nemo_asr.models.ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
        print("✓ Parakeet downloaded successfully")
        
        output_path = os.path.abspath("local_models/parakeet.nemo")
        os.makedirs("local_models", exist_ok=True)
        
        model.save_to(output_path)
        print(f"✓ Saved to {output_path}")
        
        if os.path.exists(output_path):
            size = os.path.getsize(output_path) / (1024**3)
            print(f"✓ Verified: {size:.2f} GB")
            return True
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    if download_and_save_parakeet():
        print("\\n✅ Parakeet setup complete!")
        print("Canary will load from HuggingFace cache automatically.")
    else:
        print("\\n❌ Setup failed")
        sys.exit(1)
```

### Step 2: Clear Canary Cache (Free Up Space)

Since Canary won't use .nemo files, clear its corrupted cache:

```powershell
Remove-Item -Recurse -Force "C:\Users\chunk\.cache\torch\NeMo\NeMo_2.6.0\hf_hub_cache\nvidia\canary-qwen-2.5b"
```

This frees up the partial ~5GB download.

### Step 3: Upload GitHub Copilot Report

Upload the diagnostic report (this document) to your repository and assign GitHub Copilot to implement the hybrid loading approach.

### Step 4: Test the Fixed Interface

After Copilot implements changes:

1. Run transcribe_ui.py
2. Test Parakeet (loads instantly from local file)
3. Test Canary (downloads on first use, then cached)
4. Verify no re-downloads on subsequent runs

---

**Priority:** Critical (Canary setup completely broken)  
**Impact:** Enables both models with hybrid approach  
**Complexity:** Medium (different loading methods, needs careful implementation)  
**Estimated Time:** 30-45 minutes for Copilot implementation

---

## Summary

Canary-Qwen-2.5B uses SALM architecture that cannot be packaged as .nemo files due to HuggingFace repo structure. Solution is to use local .nemo for Parakeet (working) and direct HuggingFace loading with pinned revision for Canary (prevents re-downloads). This hybrid approach provides best of both: instant loading for Parakeet, cached loading for Canary, no re-download loops.
