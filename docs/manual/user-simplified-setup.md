# User Action Guide: Simplified Setup (Parakeet Only)

**What Happened:** Canary-Qwen-2.5B cannot be saved as a .nemo file due to its SALM architecture  
**Solution:** Setup Parakeet locally, let Canary load from HuggingFace cache automatically

---

## What You Need to Know

### The Problem

Canary-Qwen-2.5B is a newer **SALM (Speech-Aware Language Model)** that HuggingFace stores differently than traditional models. When you tried to save it as a .nemo file, it failed because:

1. **HuggingFace hosts Canary as raw model files** (safetensors format)
2. **NeMo's save_to() expects a model_config.yaml file** that doesn't exist in the repo
3. **Parakeet works fine** because it's a traditional model packaged as .nemo

This is NOT your fault - it's a known limitation of SALM models.

### The Solution

**Use a hybrid approach:**
- ✅ **Parakeet:** Save as local .nemo file (works perfectly)
- ✅ **Canary:** Load directly from HuggingFace with pinned revision (prevents re-downloads)

Both models will work, you'll just load them differently.

---

## Step 1: Setup Parakeet Only

### Create Simplified Setup Script

Delete your old `setup_local_models.py` and replace with this:

```python
#!/usr/bin/env python3
"""
Simplified setup: Only downloads and saves Parakeet as .nemo file.
Canary will load from HuggingFace cache automatically.
"""

import nemo.collections.asr as nemo_asr
import os
import sys

def setup_parakeet():
    """Download Parakeet and save as .nemo file."""
    
    print("\\n" + "="*80)
    print("📦 Setting Up Parakeet-TDT-0.6B v2")
    print("="*80)
    print("\\nThis will:")
    print("  1. Download Parakeet from HuggingFace (~1.2 GB)")
    print("  2. Save as local .nemo file")
    print("  3. Take ~5-10 minutes")
    print("\\nNote: Canary will be set up automatically by GitHub Copilot")
    print("      to load from HuggingFace cache (no .nemo file needed)\\n")
    
    response = input("Continue? (y/n): ").strip().lower()
    if response != 'y':
        print("❌ Setup cancelled")
        sys.exit(0)
    
    try:
        # Create directory
        os.makedirs("local_models", exist_ok=True)
        print("✓ Created local_models/ directory")
        
        # Download Parakeet
        print("\\n📥 Downloading Parakeet...")
        model = nemo_asr.models.ASRModel.from_pretrained("nvidia/parakeet-tdt-0.6b-v2")
        print("✓ Download complete")
        
        # Save as .nemo
        print("\\n💾 Saving to local_models/parakeet.nemo...")
        output_path = os.path.abspath("local_models/parakeet.nemo")
        model.save_to(output_path)
        
        # Verify
        if os.path.exists(output_path):
            size = os.path.getsize(output_path) / (1024**3)
            print(f"✓ Saved successfully ({size:.2f} GB)")
            
            print("\\n" + "="*80)
            print("✅ Parakeet Setup Complete!")
            print("="*80)
            print(f"\\nSaved to: {output_path}")
            print("\\nNext steps:")
            print("  1. Upload canary-hybrid-loading-fix.md to GitHub")
            print("  2. Let GitHub Copilot implement Canary loading")
            print("  3. Run transcribe_ui.py")
            print("\\nCanary will download on first use (~5GB), then load from cache")
            print("="*80 + "\\n")
            return True
        else:
            print("❌ File was not created")
            return False
            
    except Exception as e:
        print(f"\\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    try:
        if not setup_parakeet():
            print("\\n❌ Setup failed. Please check error above.")
            sys.exit(1)
    except KeyboardInterrupt:
        print("\\n\\n❌ Setup interrupted")
        sys.exit(1)
```

### Run the Simplified Setup

```powershell
python setup_local_models.py
```

**Expected output:**
```
================================================================================
📦 Setting Up Parakeet-TDT-0.6B v2
================================================================================

This will:
  1. Download Parakeet from HuggingFace (~1.2 GB)
  2. Save as local .nemo file
  3. Take ~5-10 minutes

Note: Canary will be set up automatically by GitHub Copilot
      to load from HuggingFace cache (no .nemo file needed)

Continue? (y/n): y

✓ Created local_models/ directory

📥 Downloading Parakeet...
[Download progress...]
✓ Download complete

💾 Saving to local_models/parakeet.nemo...
✓ Saved successfully (2.38 GB)

================================================================================
✅ Parakeet Setup Complete!
================================================================================

Saved to: E:\\Chunky's Master Folder\\myEditingScripts\\local_models\\parakeet.nemo

Next steps:
  1. Upload canary-hybrid-loading-fix.md to GitHub
  2. Let GitHub Copilot implement Canary loading
  3. Run transcribe_ui.py

Canary will download on first use (~5GB), then load from cache
================================================================================
```

---

## Step 2: Clean Up Canary's Broken Cache

Free up the ~5GB from the failed Canary downloads:

```powershell
Remove-Item -Recurse -Force "C:\\Users\\chunk\\.cache\\torch\\NeMo\\NeMo_2.6.0\\hf_hub_cache\\nvidia\\canary-qwen-2.5b"
```

This deletes the partial downloads that can't be used.

---

## Step 3: Upload GitHub Copilot Report

1. Upload `canary-hybrid-loading-fix.md` to your myEditingScripts repository
2. Assign GitHub Copilot to implement the changes
3. Wait for Copilot to modify transcribe_ui.py

---

## Step 4: Test the Fixed Interface

After GitHub Copilot completes:

```powershell
python transcribe_ui.py
```

### Expected Behavior

**First Time Running:**
```
✅ GPU: NVIDIA GeForce RTX 4080 Laptop GPU
✅ Models: Parakeet local, Canary from cache

Opening in browser...
```

**When you use Parakeet:**
```
Loading parakeet model...
✓ parakeet loaded successfully (2.1 seconds)
[Transcription works]
```

**When you use Canary (first time):**
```
Loading canary model...
Downloading Canary from HuggingFace (this happens once)...
[Downloads ~5GB, takes 10-15 minutes]
✓ canary loaded successfully (15.3 seconds)
[Transcription works]
```

**When you use Canary (subsequent times):**
```
Loading canary model...
✓ canary loaded successfully (3.2 seconds)  ← Fast! Using cache
[Transcription works]
```

---

## How It Works

### Parakeet (Local .nemo)
- **Location:** local_models/parakeet.nemo (~2.4GB on disk)
- **Loading:** Instant (~2 seconds)
- **Internet:** Not required
- **Re-downloads:** Never

### Canary (HuggingFace Cache)
- **Location:** C:\Users\chunk\\.cache\torch\NeMo\... (~5.3GB on disk)
- **Loading:** First time ~15 seconds (download), then ~3 seconds (cache)
- **Internet:** Required only on first use
- **Re-downloads:** Never (revision pinned)

### Both Models
- **Memory cache:** After first load, models stay in RAM
- **Subsequent transcriptions:** Instant (no reload needed)
- **Session restart:** Models reload from disk/cache (~2-3 seconds)

---

## Troubleshooting

### "Parakeet setup failed"

**Check:**
1. Internet connection working?
2. At least 5GB free disk space?
3. Antivirus blocking downloads?

**Try:**
```powershell
# Run as Administrator
python setup_local_models.py
```

### "Canary loading failed"

**Check:**
1. Internet connection on first use?
2. At least 10GB free disk space?
3. HuggingFace accessible?

**Try:**
```powershell
# Clear cache and retry
Remove-Item -Recurse -Force "C:\\Users\\chunk\\.cache\\torch\\NeMo"
# Then run transcribe_ui.py again
```

### "Both models slow to load"

**Check:**
- Are models in memory cache?
- Did you restart the script?

**Expected:**
- First load in session: 2-3 seconds (from disk/cache)
- Subsequent uses: Instant (from memory)

---

## Advantages of Hybrid Approach

✅ **Best of both worlds:**
- Parakeet: Instant loading, completely offline
- Canary: Cached loading, no re-download loop

✅ **Disk space efficient:**
- Parakeet: 2.4GB local
- Canary: 5.3GB cache
- Total: ~8GB (vs. trying to store both as .nemo)

✅ **No maintenance:**
- Parakeet .nemo stable forever
- Canary revision pinned (won't auto-update)

✅ **Reliable:**
- No more infinite re-download loops
- No cache corruption issues
- Predictable behavior

---

## Summary

**What you're doing:**
1. ✅ Setup Parakeet as local .nemo (works perfectly)
2. ✅ Let Copilot implement Canary loading from cache
3. ✅ Both models work, no re-downloads

**What you're NOT doing:**
- ❌ Trying to create Canary .nemo (impossible due to SALM architecture)
- ❌ Using Solution #2 from original guide (that was for both models)
- ❌ Dealing with cache corruption issues anymore

**Time investment:**
- Setup Parakeet: 10 minutes
- Copilot implementation: 30 minutes
- First Canary load: 15 minutes
- Total: ~1 hour, then permanent solution

**Result:**
Both models working reliably with no re-download loops!
