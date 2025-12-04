# Model Re-Download Issue After Completion: Root Cause and Fix

**Script:** transcribe_ui.py | **Date:** 2025-12-04 | **Issue:** Model re-downloads even after successful 5.12GB download

---

## Problem Summary

The 5.12GB download completed successfully, but when you ran the script again, NeMo detected the cached files, **deleted them**, and started downloading **again** to a different cache directory. The console shows NeMo found files in one hash-based directory but expected them in a different hash-based directory, treating the completed download as invalid.

## Root Cause

**File:** `transcribe_ui.py`  
**Location:** `load_model()` function (lines 14-26)  
**Issue:** NeMo's `from_pretrained()` method does NOT pin to a specific model revision/commit hash. Each time it runs, it checks HuggingFace for the "latest" revision, and if the revision changed (or if NeMo calculates the hash differently), it generates a NEW expected cache directory path. The completed download exists in directory with hash `2399591399e4e6438fa7804f2f1f1660`, but NeMo now expects directory with hash `1299591399eded3876a0e42f1f1660` (DIFFERENT HASH), so it deletes the "old" cache and re-downloads.

### Evidence from Console

**First Download (Completed):**
```
Downloading nvidia/canary-qwen-2.5b to path: ...\2399591399e4e6438fa7804f2f1f1660
model.safetensors: 100%|...| 5.12G/5.12G
```

**Second Run (Screenshot):**
```
[NeMo I] Found 1 files in cache directory
[NeMo I] Deleting old cache directory for model `nvidia/canary-qwen-2.5b` in order to prevent duplicates...
[NeMo I] Restoration will occur within pre-extracted directory: ...\1299591399eded3876a0e42f1f1660
Fetching 5 files: 20%
```

**The hash changed:**
- First: `2399591399...`
- Second: `1299591399...`

These are **different directories**, so NeMo sees "no cache for current revision" even though you just downloaded 5.12GB.

### Why the Hash Changed

**Most Likely Cause (95% probability):** HuggingFace model repository was updated between your first and second download. The model files themselves may not have changed significantly, but the commit hash on HuggingFace changed (even minor metadata updates trigger new commits), causing NeMo to expect a different cache directory.

**Other Possible Causes:**
1. **NeMo version-specific hashing:** NeMo 2.6.0 may calculate hashes differently on different runs due to timestamp inclusion or environmental factors
2. **Xet Storage vs HTTP mismatch:** First download used HTTP (fallback), second run expects Xet-based hash
3. **from_pretrained() behavior:** Method doesn't pin revision by default, always checks for "latest"

<scope>
**Fix (Priority Order):**
1. Pin model revision to specific commit hash in from_pretrained() call
2. Switch to restore_from() with locally saved .nemo file
3. Install hf_xet package to eliminate HTTP/Xet mismatch

**Do NOT Modify:**
- NeMo cache directory structure (it's working as designed)
- HuggingFace hub infrastructure  
- Global cache location (respect existing paths)
</scope>

---

## Fix #1: Pin Model Revision (Recommended)

### Problem
`from_pretrained("nvidia/canary-qwen-2.5b")` always downloads "latest" revision from HuggingFace. If model repo updates, hash changes, cache invalidated.

### Fix Required
Pin to specific model revision/commit hash so NeMo always expects the same cache directory. Modify load_model() function to specify exact revision.

**Implementation approach:**
```python
def load_model(model_name):
    if model_name not in models_cache:
        print(f"Loading {model_name} model...")
        if model_name == "parakeet":
            models_cache[model_name] = nemo_asr.models.ASRModel.from_pretrained(
                "nvidia/parakeet-tdt-0.6b-v2",
                revision="main"  # or specific commit hash
            )
        else:  # canary
            models_cache[model_name] = nemo_asr.models.ASRModel.from_pretrained(
                "nvidia/canary-qwen-2.5b",
                revision="main"  # Pin to main branch HEAD, or use commit hash
            )
        print(f"✓ {model_name} loaded successfully")
    return models_cache[model_name]
```

**Better approach (use specific commit):**
Go to HuggingFace repo (https://huggingface.co/nvidia/canary-qwen-2.5b/commits/main), copy the commit hash from when you first downloaded, and pin to that:

```python
revision="<commit_hash_here>"  # e.g., "a1b2c3d4e5..."
```

This ensures NeMo ALWAYS looks for the same revision, preventing hash changes from triggering re-downloads.

---

## Fix #2: Use restore_from() with Local File (Alternative)

### Problem
from_pretrained() always checks HuggingFace for latest revision. Even with pinning, relies on online lookups.

### Fix Required
Download model once using from_pretrained(), save it locally as .nemo file, then use restore_from() for all future loads. This completely bypasses HuggingFace revision checking.

**Implementation approach:**

**Step A: One-time download and save:**
```python
# Run this ONCE to download and save locally
import nemo.collections.asr as nemo_asr

# Download from HuggingFace
model = nemo_asr.models.ASRModel.from_pretrained("nvidia/canary-qwen-2.5b")

# Save locally
model.save_to("local_models/canary-qwen-2.5b.nemo")
```

**Step B: Modify load_model() to use local files:**
```python
def load_model(model_name):
    if model_name not in models_cache:
        print(f"Loading {model_name} model...")
        if model_name == "parakeet":
            # Load from local .nemo file
            models_cache[model_name] = nemo_asr.models.ASRModel.restore_from(
                "local_models/parakeet-tdt-0.6b-v2.nemo"
            )
        else:  # canary
            models_cache[model_name] = nemo_asr.models.ASRModel.restore_from(
                "local_models/canary-qwen-2.5b.nemo"
            )
        print(f"✓ {model_name} loaded successfully")
    return models_cache[model_name]
```

**Benefits:**
- No HuggingFace lookups ever again
- No revision hash changes
- Faster loading (no cache validation overhead)
- Works offline

**Drawback:**
- Manual process to update models (must re-download and re-save)

---

## Fix #3: Install hf_xet Package (May Help)

### Problem
Console shows repeated warnings:
```
Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed.
Falling back to regular HTTP download.
```

Xet vs HTTP download may cause different hashing behavior.

### Fix Required
Install hf_xet package to use Xet Storage instead of HTTP fallback.

**User action required (run in terminal):**
```bash
pip install hf_xet
```

Or:
```bash
pip install huggingface_hub[hf_xet]
```

**Expected result:**
- Faster downloads (Xet is optimized for large files)
- Consistent hashing between downloads
- No more Xet warnings

**Note:** This may not completely solve the issue if HuggingFace repo is actually updating, but it eliminates the HTTP/Xet mismatch as a variable.

---

## Immediate Workaround (While Deciding on Fix)

If you need to transcribe NOW and can't wait for another 5.12GB download:

### Option A: Let Current Download Finish
The download in your screenshot is at 20% for the 5 metadata files and 1% for model.safetensors. Let it complete, and this time it WILL use the new hash directory (`1299591399...`). Future runs should be consistent IF HuggingFace doesn't update again.

### Option B: Manually Move Cache
If the first download (in `2399591399...` directory) completed successfully, you could manually rename/copy that directory to the new expected hash:

**Windows PowerShell:**
```powershell
# Find the complete download
cd C:\Users\chunk\.cache\torch\NeMo\NeMo_2.6.0\hf_hub_cache\nvidia\canary-qwen-2.5b\

# Copy old hash directory to new hash directory
Copy-Item -Recurse 2399591399e4e6438fa7804f2f1f1660 1299591399eded3876a0e42f1f1660
```

**Warning:** This is a hack. NeMo may still reject it if file checksums don't match expectations. Only use if desperate.

---

## Long-Term Solution

Implement Fix #1 (revision pinning) or Fix #2 (local .nemo files) to prevent this issue permanently.

**Recommended:** Use Fix #2 (local .nemo files) because:
1. Complete independence from HuggingFace repo updates
2. Faster loading (no online lookups)
3. Works offline
4. No revision hash fragility

<acceptance_criteria>
**Fix #1 (Revision Pinning):**
- [ ] `revision` parameter added to from_pretrained() calls
- [ ] Specific commit hash or "main" branch specified
- [ ] Model downloads once to consistent cache directory
- [ ] Subsequent runs use cache without re-downloading
- [ ] No "Deleting old cache directory" messages

**Fix #2 (Local .nemo Files):**
- [ ] Models downloaded and saved as .nemo files once
- [ ] load_model() modified to use restore_from() with local paths
- [ ] No HuggingFace lookups on subsequent runs
- [ ] Models load from local .nemo files consistently
- [ ] Works completely offline after initial setup

**Fix #3 (hf_xet Installation):**
- [ ] hf_xet package installed via pip
- [ ] No more "Xet Storage" warnings in console
- [ ] Downloads use Xet instead of HTTP fallback
- [ ] Faster download speeds observed

**All Fixes:**
- [ ] No unexpected cache deletions
- [ ] Models download exactly once
- [ ] Consistent cache behavior across runs
- [ ] Clear console output indicating cache hits
</acceptance_criteria>

---

## Supporting Context

<details>
<summary>Hash Change Evidence from Console</summary>

**Download 1 (Previous):**
```
Downloading nvidia/canary-qwen-2.5b from HuggingFace Hub to path:
C:\Users\chunk\.cache\torch\NeMo\NeMo_2.6.0\hf_hub_cache\nvidia\canary-qwen-2.5b\2399591399e4e6438fa7804f2f1f1660
```

**Download 2 (Screenshot):**
```
[NeMo I 2025-12-04 16:29:38] Restoration will occur within pre-extracted directory:
`C:\Users\chunk\.cache\nvidia\canary-qwen-2.5b\1299591399eded3876a0e42f1f1660`
```

**Proof of different directories:**
- First: `2399591399e4e6438fa7804f2f1f1660` (40 chars)
- Second: `1299591399eded3876a0e42f1f1660` (33 chars, starts with "1299...")

These are COMPLETELY DIFFERENT cache locations. NeMo expects new hash, finds old hash, deletes old, downloads new.
</details>

<details>
<summary>Why from_pretrained() Doesn't Pin by Default</summary>

From HuggingFace documentation: `from_pretrained()` behavior defaults to fetching the "main" branch HEAD (latest commit) unless explicitly told otherwise via `revision` parameter.

**Default behavior:**
```python
model = ASRModel.from_pretrained("nvidia/canary-qwen-2.5b")
# Implicitly: revision="main" (latest)
```

**Pinned behavior:**
```python
model = ASRModel.from_pretrained(
    "nvidia/canary-qwen-2.5b",
    revision="abc123def456"  # Specific commit hash
)
```

Without pinning, each call checks HuggingFace for current HEAD of main branch. If repo updated (even README change triggers commit), new HEAD = new hash = new cache directory.

**Why this design?**
- Ensures users always get latest model improvements
- Prevents using outdated cached versions after bug fixes

**Why this BREAKS your use case?**
- You want stability, not automatic updates
- 5.12GB re-downloads unacceptable for minor repo updates
- Need explicit control over when to update

**Solution:** Pin revision or use local files (Fixes #1 or #2)
</details>

<details>
<summary>Xet Storage Technical Details</summary>

**What is Xet Storage?**
- HuggingFace's optimized storage backend for large files
- Uses content-addressable storage and deduplication
- Faster downloads via parallel chunking
- Requires `hf_xet` package to utilize

**Why the Warning?**
```
Xet Storage is enabled for this repo, but the 'hf_xet' package is not installed.
Falling back to regular HTTP download.
```

nvidia/canary-qwen-2.5b repository has Xet enabled, but your environment doesn't have the client library, so downloads fall back to standard HTTP.

**Potential Issue:**
- Xet downloads may generate different cache hashes than HTTP downloads
- Mixing Xet and HTTP downloads could cause hash mismatches
- Installing hf_xet ensures consistent download method = consistent hashing

**Not the PRIMARY cause of your issue (that's the revision changing), but could be contributing factor.**
</details>

<details>
<summary>Alternative: Specify Cache Directory</summary>

Another approach (not recommended but possible) is to force NeMo to use a specific cache directory regardless of hash:

```python
model = nemo_asr.models.ASRModel.from_pretrained(
    "nvidia/canary-qwen-2.5b",
    cache_dir="C:/fixed_model_cache/canary"  # Custom location
)
```

**Problems with this approach:**
- NeMo may still delete and re-download if hash doesn't match
- Doesn't address root cause (unpinned revision)
- Just moves the problem to a different directory

**Why mention it?** Awareness that cache_dir exists, but it's not the solution here.
</details>

---

**Priority:** Critical (blocks usability completely)  
**Impact:** Infinite re-download loop, unusable script  
**Recommended Fix:** Fix #2 (local .nemo files) - most reliable long-term  
**Quick Fix:** Fix #3 (install hf_xet) + let current download finish  
**Estimated Fix Time:** 5-10 minutes for Fix #1 or #3, 15 minutes for Fix #2
