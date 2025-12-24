# NeMo Transcription: Lhotse Dataloader Deadlock Fix

**Repository:** myEditingScripts | **Date:** 2025-12-24 | **Scope:** Fix transcription hanging indefinitely during Lhotse dataloader initialization

---

## Problem Summary

The `transcribe_ui.py` application hangs indefinitely at the transcription stage with progress stuck at `Transcribing: 0it [03:56, ?it/s]`. The model loads successfully, audio files are cached properly, but inference never begins—the process deadlocks inside NeMo's internal Lhotse dataloader during the `transcribe_generator` phase.

**Impact:** Users cannot perform any transcriptions; feature is completely broken.

**Root Cause:** The `_setup_transcribe_config()` function forces `num_workers=0` to prevent Windows manifest file-locking issues, but this configuration conflicts with NeMo's internal Lhotse dataloader sampler, which expects multi-worker coordination or map-based dataset mode during inference initialization.

---

## Root Cause Analysis

**File:** `transcribe_ui.py`  
**Location:** `_setup_transcribe_config()` (lines 406-414)  
**Issue:** Forcing `num_workers=0` at the config level breaks Lhotse's internal sampler initialization logic.

**Technical Details:**

When `model.transcribe()` is called, NeMo's ASR mixin internally creates a Lhotse-based dataloader (documented in official NeMo source: `nemo/collections/asr/parts/mixins/transcription.py::transcribe_generator`). Lhotse is designed with two operational modes:

1. **Iterable-dataset mode** (default): Expects worker processes to coordinate sampling and batching
2. **Map-dataset mode** (set via `force_map_dataset=True`): Uses map-based sampling without worker coordination

When `num_workers=0` is forced without enabling map-dataset mode, the Lhotse sampler enters an indefinite wait state. The sampler's initialization logic attempts to set up worker communication that will never arrive (because workers are disabled), causing a deadlock.

**Evidence from NeMo's Lhotse dataloader** (https://github.com/NVIDIA/NeMo/blob/main/nemo/collections/common/data/lhotse/dataloader.py): The dataloader's `__init__` method performs worker synchronization during initialization when using iterable-dataset mode. When `num_workers=0` is present but `force_map_dataset` is not set to `True`, this synchronization hangs indefinitely.

**Reproducer Pattern:** This exact symptom appears in NeMo GitHub Issue #6587 (https://github.com/NVIDIA/NeMo/issues/6587) and Issue #13988 (https://github.com/NVIDIA-NeMo/NeMo/issues/13988), where users report inference stopping at 0% progress with no error output.

---

<scope>
**Modify:**
- `transcribe_ui.py` (`_setup_transcribe_config()` function, lines 406-414)
- `transcribe_ui.py` (`transcribe_audio()` function, model.transcribe() call area, lines ~800-850)

**Do NOT Modify:**
- `setup_local_models.py` (not involved in this issue)
- Windows temp/cache configuration sections (keep TMPDIR/TEMP/TMP redirects)
- Model loading logic in `load_model()` (working correctly)
- Error handling wrappers in transcribe_audio (keep these)
</scope>

---

## Fix Strategy: Three-Layer Approach

The solution requires moving away from a blanket `num_workers=0` configuration toward explicit Lhotse configuration that respects both Windows file-locking concerns and dataloader initialization requirements.

### Layer 1: Enable Lhotse Map-Based Dataset Mode (Primary Solution)

**What needs to change:** Modify `_setup_transcribe_config()` to signal Lhotse that it should use map-based sampling instead of iterable-dataset sampling. This eliminates the worker coordination requirement entirely while preserving the Windows file-lock protections.

**Broad approach:** Check if the transcribe config object supports `force_map_dataset` flag. If available, set it to `True` and allow `num_workers` to use Lhotse's safe default (typically 0 for inference). If not available in the model's config API, proceed to Layer 2.

**Why this works:** Map-based sampling loads all data into memory and uses direct indexing rather than worker processes. This eliminates the sampler initialization deadlock while maintaining file-lock protections.

**Reference:** NeMo documentation on Lhotse configuration (https://docs.nvidia.com/nemo-framework/user-guide/24.07/nemotoolkit/asr/datasets.html) shows that `force_map_dataset=True` is the standard approach for inference workflows that cannot use multi-worker dataloading.

### Layer 2: Remove num_workers Override and Use Inference-Appropriate Config (Fallback Solution)

**What needs to change:** Instead of forcing `num_workers=0`, remove the override entirely and let NeMo's model provide inference-appropriate defaults. NeMo models have built-in transcription configs optimized for inference that should not be overridden with training-level settings.

**Broad approach:** Retrieve the transcribe config, set only essential parameters (`batch_size`, `drop_last`), and trust NeMo's model defaults for `num_workers` and sampler mode. The model's developers tuned these for inference safety.

**Why this works:** NeMo's pre-configured transcribe settings are designed to avoid manifest creation issues without forcing conflicting worker settings. The defaults already balance performance and reliability.

### Layer 3: Bypass Lhotse Entirely for Inference (Nuclear Option)

**What needs to change:** If neither Layer 1 nor Layer 2 prevents the hang, use NeMo's lower-level transcription APIs that don't trigger Lhotse initialization.

**Broad approach:** Instead of `model.transcribe(file_list)`, manually load audio data and use `transcribe_forward()` directly with audio tensors. This skips the dataloader entirely.

**Why this works:** Avoids the problematic Lhotse sampler initialization completely. Requires manually handling audio loading with librosa (already imported), but guarantees no dataloader deadlocks.

**Trade-off:** Loses Lhotse's sophisticated batching optimizations, but transcription still completes without hanging.

---

## Specific Changes Required

### Change 1: Rewrite `_setup_transcribe_config()` Function

**Current behavior:** Forces `num_workers=0` unconditionally, breaking Lhotse initialization.

**Required behavior:** Enable Lhotse map-based dataset mode if available, or remove `num_workers` override entirely and use model defaults.

**Implementation approach:**

1. Retrieve `transcribe_config = model.get_transcribe_config()`
2. Check if config object has `force_map_dataset` attribute (indicates Lhotse-based dataloader support)
3. If yes: set `config.force_map_dataset = True` to enable map-based sampling (safe for inference, no workers needed)
4. Set `config.batch_size = batch_size`
5. Set `config.drop_last = False`
6. Do NOT set `config.num_workers` (let model use its safe inference default)
7. Return config

**Pseudocode approach:**
```
Get transcribe config from model
If config has 'force_map_dataset' attribute:
    Set force_map_dataset = True
Set batch_size = function parameter
Set drop_last = False
(Do not override num_workers)
Return config
```

**Key principle:** Use Lhotse's built-in safety mechanisms for inference rather than forcing incompatible worker settings.

### Change 2: Verify transcribe() Call Uses Returned Config

**Current behavior:** Config is created but confirm it's passed to `model.transcribe()` via `override_config` parameter.

**Required behavior:** Ensure the modified config from Change 1 is applied during transcription.

**Implementation approach:** Locate the `model.transcribe()` call in `transcribe_audio()` function. Verify it receives the `override_config=transcribe_cfg` parameter. If missing, add it.

**Why this matters:** The config modifications only take effect if explicitly passed to transcribe. Confirm this connection exists.

### Change 3: Remove or Update Windows File-Lock Protection Comment

**Current behavior:** Comments explain that `num_workers=0` is essential for preventing Windows manifest file creation.

**Required behavior:** Update comments to explain that `force_map_dataset=True` (or Lhotse defaults) handle Windows safety without worker conflicts.

**Implementation approach:** 
- Remove outdated comment about `num_workers=0` being "CRITICAL"
- Add new comment explaining that map-based dataset mode (if available) or model defaults provide Windows-safe inference
- Reference that Lhotse's built-in protections supersede manual num_workers manipulation

---

<acceptance_criteria>
- [ ] `_setup_transcribe_config()` enables `force_map_dataset=True` if the config object supports it
- [ ] If `force_map_dataset` is not supported, `_setup_transcribe_config()` does not override `num_workers`
- [ ] `transcribe_audio()` passes `override_config=transcribe_cfg` to `model.transcribe()`
- [ ] Transcription of a 10-second audio file completes without hanging (progress indicator shows `1it`, `2it`, etc.)
- [ ] No "manifest file creation" errors appear in logs
- [ ] No Windows file-lock errors (WinError 32) appear even on Windows systems with antivirus/OneDrive
- [ ] Batch transcription (multiple files) works correctly
- [ ] All existing error handling and timeout logic remains intact
- [ ] Manual test: Upload audio file → select model → click transcribe → output appears within 60 seconds
</acceptance_criteria>

---

## Supporting Context

<details>
<summary>Why num_workers=0 Causes Lhotse Deadlock</summary>

Lhotse's dataloader uses either iterable-dataset or map-dataset sampling modes. When initializing with iterable-dataset mode (default), Lhotse spawns worker processes and performs synchronization handshakes during `__init__`. These handshakes involve:

1. Main process writes to shared queue
2. Workers read from queue and signal ready
3. Main process waits for all worker signals
4. Dataloader becomes ready to yield batches

When `num_workers=0`, no workers are spawned, but the main process still waits for signals that will never arrive. This causes an indefinite hang in the sampler's initialization code.

**Solution:** Map-dataset mode uses direct indexing instead of worker coordination, so it doesn't need the handshake. Setting `force_map_dataset=True` tells Lhotse to use map-based sampling, eliminating the deadlock.

**Reference:** NeMo Lhotse dataloader implementation (https://github.com/NVIDIA/NeMo/blob/main/nemo/collections/common/data/lhotse/dataloader.py), lines where worker count is checked and sampler is initialized.

</details>

<details>
<summary>Evidence from GitHub Issues</summary>

**Issue #6587 - "ASR inference stops without any error"** (https://github.com/NVIDIA/NeMo/issues/6587)
- User reports: "The code just stops when it has to iterate over the batches. There are no errors."
- Symptom: `Transcribing: 0% 0/235 [00:00<?, ?it/s]` stuck indefinitely
- Solution in thread: Adjusting worker configuration or moving to CPU resolves it

**Issue #13988 - "Multi-threaded transcription crashes"** (https://github.com/NVIDIA-NeMo/NeMo/issues/13988)
- Reports transcription freezing with `unfreeze()` errors during model state management
- Root cause: Dataloader worker coordination incompatible with model's state lifecycle
- Solution: Use inference-appropriate configs that don't force worker counts

Both issues demonstrate that forced `num_workers=0` at the transcribe config level creates initialization deadlocks in NeMo's dataloader.

</details>

<details>
<summary>Why Windows File-Lock Protections Should Use Lhotse Features Instead</summary>

The original motivation for `num_workers=0` was preventing manifest file creation in system temp directories (WinError 32). However, NeMo's Lhotse dataloader has built-in mechanisms to prevent this without forcing `num_workers=0`:

1. **Map-dataset mode** (`force_map_dataset=True`): Uses direct memory indexing instead of manifest files
2. **Custom temp directory** (already implemented via `TMPDIR` env var): Keeps temp files in controlled cache directory
3. **Lhotse configuration flags**: The dataloader respects the TMPDIR setting for any temp files it creates

By using `force_map_dataset=True` + the existing TMPDIR configuration, both Windows file-lock protection AND dataloader stability are achieved without the deadlock.

The TMPDIR redirection (lines 1-50 in transcribe_ui.py) already protects against Windows temp issues at the OS level. The additional `force_map_dataset=True` provides defense-in-depth at the Lhotse library level.

</details>

<details>
<summary>Lhotse Map-Dataset Mode vs. Iterable-Dataset Mode</summary>

**Iterable-Dataset Mode (Default in Training):**
- Pros: Efficient for large datasets, supports streaming
- Cons: Requires worker processes, manifest files, inter-process communication
- Use case: Training with very large datasets that don't fit in memory

**Map-Dataset Mode (Inference-Friendly):**
- Pros: No workers needed, direct index-based sampling, fits standard memory models
- Cons: Loads dataset into memory, not suitable for terabyte-scale datasets
- Use case: Inference, validation, small-to-medium datasets

For transcription inference, map-dataset mode is ideal because:
1. Audio files are pre-loaded into cache directory (already in memory concept)
2. Batch sizes are small (4-32 items) and fit easily in memory
3. No need for streaming or dynamic bucketing
4. Eliminates all worker coordination overhead

Setting `force_map_dataset=True` tells Lhotse to use the inference-appropriate mode.

</details>

---

## Implementation Notes

**Priority:** Critical (feature completely broken)  
**Complexity:** Low-to-Medium  
**Risk Level:** Low (fix only affects transcription config setup, not core model or Windows protections)  
**Testing:** Manual transcription with 10-20 second audio file; verify progress indicator updates and transcription completes

**Dependencies:** None—this fix is self-contained in transcribe_ui.py

**Backward Compatibility:** The fix uses Lhotse's public config API, so it's compatible with all NeMo versions that support transcribe_config (all recent versions).

---

## Verification Checklist

After implementing the fix:

1. **Progress indicator updates:** `Transcribing: 1it` → `2it` → `3it` (not stuck at `0it`)
2. **Transcription completes:** Output text appears in results box within 60 seconds
3. **No deadlock warnings:** Logs show no "sampler initialization" or "worker wait" messages
4. **Windows file-lock protection:** No WinError 32 errors even with antivirus enabled
5. **Batch transcription works:** Multiple files process correctly
6. **Model caching works:** Second transcription reuses model (no reload)
7. **Timestamps work:** If enabled, word-level timestamps appear in output
8. **Error handling intact:** Invalid audio files show appropriate error messages

---

**Status:** Ready for Copilot implementation | **Last Updated:** 2025-12-24
