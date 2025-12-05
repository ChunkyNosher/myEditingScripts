# SALM Import Fix: Add SpeechLM2 Support for Canary Model

**Script:** transcribe_ui.py | **Date:** 2025-12-04 | **Issue:** ImportError - SALM module not available when loading Canary-Qwen-2.5B

---

## Problem Summary

Canary-Qwen-2.5B requires the **SALM (Speech-Aware Language Model)** class from `nemo.collections.speechlm2.models`, but the current code attempts to load it using the wrong class (ASRModel) and lacks the necessary import. When the UI tries to use Canary, it fails with "SALM MODULE NOT AVAILABLE!" because:

1. The speechlm2 collection is not imported
2. The code uses wrong model class (ASRModel instead of SALM)
3. No error handling for missing SALM module
4. No startup validation to check SALM availability

**This issue requires BOTH user action (upgrade NeMo) AND code changes (proper SALM import).**

<scope>
**Modify:**
- `transcribe_ui.py` (add SALM import, update load_model, add validation)
- Error handling for missing SALM module
- Startup checks for speechlm2 availability
- UI documentation about SALM requirements

**Do NOT Modify:**
- Parakeet loading (uses ASRModel correctly)
- Transcription logic
- GPU optimizations
- Gradio interface structure
</scope>

---

## Root Cause

**File:** `transcribe_ui.py`  
**Location:** Import section and load_model() function  

**Current Implementation (WRONG):**
```python
import nemo.collections.asr as nemo_asr

def load_model(model_name):
    ...
    else:  # canary
        models_cache[model_name] = nemo_asr.models.ASRModel.from_pretrained(
            "nvidia/canary-qwen-2.5b"
        )
```

**Issue:** Canary-Qwen-2.5B is a SALM model, not an ASR model. It requires importing from `nemo.collections.speechlm2.models` and using the `SALM` class. The official NVIDIA documentation and HuggingFace model card specify this requirement.

**Evidence from NVIDIA docs:**
```python
from nemo.collections.speechlm2.models import SALM
model = SALM.from_pretrained('nvidia/canary-qwen-2.5b')
```

---

## Fix Required

### Change 1: Add SALM Import with Error Handling

**Problem:** No import of speechlm2 collection, causing ImportError when trying to use SALM.

**Fix Required:**
Add import for SALM class at top of file with try-except to handle missing module gracefully. This allows the script to start even if speechlm2 is not installed, but provides clear error message when user tries to use Canary.

**Expected behavior:**
- Try to import SALM from nemo.collections.speechlm2.models
- If successful: SALM available, Canary can be loaded
- If ImportError: Set SALM_AVAILABLE flag to False, provide clear error when Canary selected
- Error message should explain that speechlm2 requires NeMo 2.6+ with [all] extras

**Implementation guidance:**
```python
# After existing imports
try:
    from nemo.collections.speechlm2.models import SALM
    SALM_AVAILABLE = True
except ImportError as e:
    SALM_AVAILABLE = False
    SALM_IMPORT_ERROR = str(e)
```

Use SALM_AVAILABLE flag to check before loading Canary model.

### Change 2: Update load_model() to Use SALM for Canary

**Problem:** Current code uses ASRModel.from_pretrained() for Canary, which is incorrect. Canary requires SALM class.

**Fix Required:**
Modify load_model() function to use SALM.from_pretrained() for Canary instead of ASRModel.from_pretrained(). Add check for SALM_AVAILABLE before attempting to load. If SALM not available, raise clear exception with setup instructions.

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
```

**Expected behavior after fix:**
- Check if model_name is "canary"
- If yes, check SALM_AVAILABLE flag first
- If SALM not available, raise ImportError with clear message about upgrading NeMo
- If SALM available, use SALM.from_pretrained("nvidia/canary-qwen-2.5b")
- Optionally add revision pinning to prevent cache issues
- Keep Parakeet loading unchanged (uses ASRModel correctly)

**Error message should include:**
- Explanation that Canary requires SALM architecture
- Instruction to upgrade NeMo: `pip install --upgrade "nemo_toolkit[all]"`
- Note that NeMo 2.6.0+ required for speechlm2 collection
- Reference to user setup documentation

### Change 3: Add Startup Validation for SALM

**Problem:** UI launches without checking if SALM is available, leading to confusing errors when user selects Canary.

**Fix Required:**
Add validation function that checks SALM availability at startup and prints warning if not available. This gives user immediate feedback about Canary availability without preventing the script from starting (Parakeet should still work).

**Expected behavior:**
- Run check in `if __name__ == "__main__":` block before app.launch()
- If SALM_AVAILABLE is False, print clear warning message
- Warning should state: "Canary model unavailable - speechlm2 not installed"
- Include upgrade instructions in warning
- Note that Parakeet will still work normally
- Do NOT exit or prevent launch (let Parakeet work)

**Implementation approach:**
Create validate_salm_availability() function that checks SALM_AVAILABLE flag and prints appropriate message. Call this after GPU checks but before launching UI.

### Change 4: Improve Error Messages in UI

**Problem:** Current error handling in transcribe_audio() doesn't specifically check for SALM issues.

**Fix Required:**
Update the exception handling in load_model() and transcribe_audio() to detect SALM-related errors and provide specific troubleshooting steps. When ImportError or AttributeError related to SALM occurs, show custom error message with upgrade instructions.

**Expected error message format:**
```
❌ SALM MODULE NOT AVAILABLE!

Model: Canary-Qwen-2.5B

Note: Canary uses SALM architecture and loads from HuggingFace cache.
First load requires internet connection (~5GB download).
Subsequent loads work offline (cached).

Problem: The nemo.collections.speechlm2 module is not installed.
Solution: Please upgrade NeMo to version 2.6.0 or later:
    pip install --upgrade "nemo_toolkit[all]"

Troubleshooting steps:
1. Check your internet connection
2. Ensure you have at least 10GB free disk space
3. Try clearing cache: Remove ~/.cache/torch/NeMo folder
4. If problem persists, check console output for details

See docs/manual/canary-hybrid-loading-fix.md for more information.
```

This provides actionable guidance instead of generic Python traceback.

### Change 5: Update UI Documentation

**Problem:** UI text doesn't mention SALM requirements or speechlm2 dependency.

**Fix Required:**
Update Gradio interface markdown sections to explain SALM requirements for Canary. Add note about speechlm2 collection and installation requirements. Update "How to Use" section to mention first-time setup needs.

**Sections to update:**
1. Main header: Add note about NeMo requirements
2. "How to Use" accordion: Add SALM installation check
3. Model Information section: Explain Canary requires speechlm2
4. Add troubleshooting section for SALM errors

**Example text to add:**
```markdown
### Requirements:
- **Parakeet:** Works with base NeMo installation
- **Canary:** Requires NeMo 2.6+ with speechlm2 collection
  - Install: `pip install --upgrade "nemo_toolkit[all]"`
  - First use downloads ~5GB from HuggingFace
  - Subsequent uses load from cache (offline)
```

---

## Implementation Notes

**SALM vs ASRModel:**
- **ASRModel:** Traditional NeMo ASR models (Parakeet, Conformer, etc.)
- **SALM:** Speech-Aware Language Model (Canary-Qwen, newer architecture)
- Different base classes, different loading methods
- Cannot use ASRModel for SALM models (incompatible)

**Why speechlm2 is separate:**
- SpeechLM2 is advanced collection for speech+language models
- Not included in base NeMo installation
- Requires `nemo_toolkit[all]` or explicit speechlm2 installation
- Available in NeMo 2.6.0+

**Revision Pinning (Optional):**
To prevent cache invalidation issues, can optionally pin Canary to specific revision:
```python
model = SALM.from_pretrained(
    "nvidia/canary-qwen-2.5b",
    revision="2399591399e4e6438fa7804f2f1f1660"  # Current version as of Dec 2024
)
```

**Import Error Handling:**
Graceful degradation approach allows script to run with Parakeet only if SALM unavailable. User gets clear error only when selecting Canary, not on script startup.

<acceptance_criteria>
**Imports:**
- [ ] SALM imported from nemo.collections.speechlm2.models with try-except
- [ ] SALM_AVAILABLE flag set based on import success
- [ ] Import error message captured for user display

**Model Loading:**
- [ ] load_model() checks SALM_AVAILABLE before loading Canary
- [ ] Uses SALM.from_pretrained() for Canary (not ASRModel)
- [ ] Raises clear error if SALM unavailable
- [ ] Parakeet loading unchanged and working

**Startup Validation:**
- [ ] validate_salm_availability() function exists
- [ ] Called before app.launch()
- [ ] Prints warning if SALM unavailable
- [ ] Does not prevent script from starting

**Error Handling:**
- [ ] SALM ImportError caught and explained
- [ ] Error message includes upgrade instructions
- [ ] References documentation for troubleshooting
- [ ] Clear actionable steps provided

**UI Documentation:**
- [ ] Requirements section mentions speechlm2 for Canary
- [ ] Installation instructions included
- [ ] Troubleshooting section updated
- [ ] Model information accurate for both models

**Functionality:**
- [ ] Parakeet works regardless of SALM availability
- [ ] Canary works when SALM available
- [ ] Clear error when Canary selected without SALM
- [ ] No regressions in existing features
- [ ] Manual test: Start without speechlm2 → Parakeet works, Canary shows clear error
- [ ] Manual test: Start with speechlm2 → Both models work
</acceptance_criteria>

---

## Supporting Context

<details>
<summary>Official NVIDIA Documentation</summary>

**From NeMo Framework Installation Guide [web:150]:**

To install all NeMo domains including speechlm2:
```bash
apt-get update && apt-get install -y libsndfile1 ffmpeg
pip install Cython packaging
pip install nemo_toolkit['all']
```

**From Canary-Qwen-2.5B HuggingFace [web:128]:**

```python
from nemo.collections.speechlm2.models import SALM
model = SALM.from_pretrained('nvidia/canary-qwen-2.5b')
```

**From SpeechLM2 Documentation [web:132]:**

The speechlm2 collection supports SALM (Speech-Aware Language Model) and DuplexS2S models. These are specialized models that combine speech understanding with language generation capabilities.

**Usage example from [web:138]:**
```python
from nemo.collections.speechlm2.models import SALM

# Load pre-trained model
model = SALM.from_pretrained('nvidia/canary-qwen-2.5b')

# Transcribe audio
transcription_result = model.generate(
    prompts=[{
        "role": "user",
        "content": f"Transcribe: {model.audio_locator_tag}",
        "audio": ["audio.wav"]
    }]
)
```
</details>

<details>
<summary>Error Context from User</summary>

**Error displayed in Gradio UI:**
```
❌ Error During Transcription

Error Type: ImportError

Error Message: SALM MODULE NOT AVAILABLE!

Model: Canary-Qwen-2.5B

Note: Canary uses SALM architecture and loads from HuggingFace cache.
First load requires internet connection (~5GB download).
Subsequent loads work offline (cached).

Problem: The nemo.collections.speechlm2 module is not installed.
Solution: Please upgrade NeMo to version 2.6.0 or later:
    pip install nemo_toolkit[all]>=2.6.0
```

**Key insights:**
- Error occurs when user selects Canary model
- Current code attempts to use SALM but import fails
- speechlm2 collection not in user's environment
- Error handling exists but needs code fix to enable SALM
</details>

<details>
<summary>Version Requirements</summary>

**NeMo Version:**
- Base NeMo: ASR models only (Parakeet works)
- NeMo 2.6.0+: Includes speechlm2 collection (Canary works)
- Install command: `pip install "nemo_toolkit[all]"`

**Python Version:**
- Requires Python 3.8+ (user likely has 3.10 from conda env)

**Dependencies:**
- PyTorch 2.0+ with CUDA support
- libsndfile1 (for audio processing)
- ffmpeg (for audio format conversion)

**Disk Space:**
- Canary model: ~5.3GB download
- NeMo installation: ~2-3GB
- Total: ~8-10GB free space needed
</details>

<details>
<summary>Import Pattern Comparison</summary>

**Parakeet (Correct - Keep as-is):**
```python
import nemo.collections.asr as nemo_asr
model = nemo_asr.models.ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
# or:
model = nemo_asr.models.ASRModel.restore_from("local_models/parakeet.nemo")
```

**Canary (Need to change):**
```python
# WRONG (current code):
import nemo.collections.asr as nemo_asr
model = nemo_asr.models.ASRModel.from_pretrained("nvidia/canary-qwen-2.5b")

# CORRECT (needed):
from nemo.collections.speechlm2.models import SALM
model = SALM.from_pretrained("nvidia/canary-qwen-2.5b")
```

**Why different:**
- Parakeet: Traditional encoder-decoder ASR architecture
- Canary: SALM architecture (speech + language model hybrid)
- Different base classes, different collections
- speechlm2 is separate optional package
</details>

---

**Priority:** Critical (Canary completely broken, requires both user and code fix)  
**Impact:** Enables Canary model with proper SALM support  
**Complexity:** Low-Medium (straightforward import fix with error handling)  
**Estimated Time:** 20-30 minutes for Copilot implementation

---

## Summary

Canary-Qwen-2.5B requires SALM class from nemo.collections.speechlm2.models, not ASRModel. Current code uses wrong class and lacks proper import. Solution is to add SALM import with error handling, update load_model() to use SALM for Canary, add startup validation, and improve error messages. User must also upgrade NeMo to version with speechlm2 collection (see user guide).
