# Transcription UI Performance & Feature Enhancement

**Script:** transcribe_ui.py | **Date:** 2025-12-04 | **Scope:** GPU/CPU optimization, batch processing, video support, model caching

---

## Executive Summary

The Gradio transcription interface has four enhancement opportunities: GPU/CPU utilization is suboptimal during transcription, there's no batch processing for multiple files, video files cannot be processed, and models must download on first run. These issues span different areas of the codebase but can be addressed in a coordinated effort to significantly improve performance and usability.

## Issues Overview

| Issue | Component | Priority | Root Cause |
|-------|-----------|----------|------------|
| #1: Incomplete GPU/CPU utilization | transcribe_audio() | High | Missing FP16 precision, pin_memory, TF32 |
| #2: No batch processing | gr.Audio + transcribe_audio() | High | Single-file design limitation |
| #3: No video file support | gr.Audio + transcribe_audio() | Medium | Audio-only input validation |
| #4: Models download on first run | load_model() | Medium | No pre-download or progress display |

**Why bundled:** All affect user experience with transcription workflow; share NeMo model architecture; can be enhanced in single coordinated update.

<scope>
**Modify:**
- `transcribe_ui.py` (transcribe_audio function, Gradio interface, load_model function)

**Do NOT Modify:**
- NeMo library internals (use existing APIs only)
- HuggingFace cache system (leverage existing mechanisms)
</scope>

---

## Issue #1: Incomplete GPU/CPU Utilization

### Problem
During transcription, GPU utilization doesn't consistently reach 90%+ and CPU cores aren't fully leveraged, resulting in slower-than-possible processing times.

### Root Cause
**File:** `transcribe_ui.py`  
**Location:** `transcribe_audio()` function (lines 43-160)  
**Issue:** The function uses FP32 precision by default (no mixed precision), lacks pin_memory optimization for CPU→GPU transfers, doesn't enable TF32 tensor cores for matrix operations, and the current batch_size range (4-16) could be more aggressive for longer audio.

### Fix Required
Enable mixed precision inference using PyTorch's autocast context manager to leverage RTX 4080's FP16 tensor cores. Add pin_memory and non_blocking transfers for data loading. Enable TF32 for matrix multiplication operations. Increase maximum batch_size to 32 for Parakeet and 16 for Canary on long audio. These changes should achieve 70-95% GPU utilization during inference phase.

---

## Issue #2: No Batch Processing for Multiple Files

### Problem
Users can only upload and transcribe one audio file at a time, making bulk transcription tedious and inefficient.

### Root Cause
**File:** `transcribe_ui.py`  
**Location:** `gr.Audio` widget initialization (line 240) and `transcribe_audio()` function signature (line 43)  
**Issue:** The gr.Audio component is configured for single file input only (default behavior), and transcribe_audio() expects a single file path string rather than a list. NeMo's model.transcribe() method natively supports multiple files in parallel but this capability isn't exposed.

### Fix Required
Change gr.Audio widget to accept multiple files by adding `file_count="multiple"` parameter. Modify transcribe_audio() to accept either a single file path or list of file paths. When receiving a list, pass entire list to model.transcribe() which handles parallel processing internally. Return aggregated results showing per-file statistics and combined transcription output. Add progress indicator for multi-file processing.

---

## Issue #3: No Video File Support

### Problem
Users cannot upload video files to extract and transcribe audio tracks, requiring manual pre-processing with external tools.

### Root Cause
**File:** `transcribe_ui.py`  
**Location:** `transcribe_audio()` function (line 43) and audio validation logic  
**Issue:** The function only validates and processes audio file extensions. While librosa.load() (used for duration detection at line 69) can actually load video files and extract audio automatically, the interface doesn't advertise this capability and file type validation may reject video formats.

### Fix Required
Detect video file formats by checking file extension against common video types (MP4, AVI, MKV, MOV, WEBM, FLV). When video detected, rely on librosa.load() which already extracts audio from video files automatically (it uses audioread/FFmpeg backend). Update UI documentation to list supported video formats. Add user feedback indicating "Extracting audio from video..." during processing. Handle edge cases where video has no audio track with clear error message.

---

## Issue #4: Models Download on First Run

### Problem
First-time users experience 20-30 second delay with no progress feedback while models download, creating confusing startup experience.

### Root Cause
**File:** `transcribe_ui.py`  
**Location:** `load_model()` function (lines 11-26)  
**Issue:** The function calls from_pretrained() which downloads models to HuggingFace cache on first invocation, but provides no progress indication. Users see interface load but get no feedback during the actual model download phase, and subsequent delay when clicking transcribe button for first time.

### Fix Required
Add startup check function that validates if models exist in cache before UI launch. If models missing, display Gradio-based progress interface showing download progress for each model using tqdm integration. Pre-load both models during startup sequence with clear status messages rather than lazy-loading on first transcription. Add retry logic for failed downloads. Provide option to specify custom cache directory for users with space constraints on default drive.

---

## Shared Implementation Notes

- **Mixed precision context:** Wrap model inference in `torch.autocast(device_type='cuda', dtype=torch.float16)` context manager. Do NOT use autocast for CPU operations or data preprocessing.
- **Backward compatibility:** Ensure single-file transcription still works exactly as before; multi-file is additive feature.
- **Video format detection:** Use simple extension check (`.mp4`, `.avi`, etc.) rather than MIME type detection for performance.
- **Model caching:** Respect existing HuggingFace cache environment variables (HF_HOME, HF_HUB_CACHE).
- **Error handling:** All new features must gracefully degrade with clear user feedback if dependencies missing (e.g., FFmpeg for video).

<acceptance_criteria>
**Issue #1 (GPU Optimization):**
- [ ] Mixed precision (FP16) enabled for model inference on CUDA
- [ ] GPU utilization reaches 70-95% during transcription (verify with nvidia-smi)
- [ ] Batch sizes increased: Parakeet max 32, Canary max 16
- [ ] TF32 enabled for matrix multiplication
- [ ] Processing speed improved by 20-40% on same audio files

**Issue #2 (Batch Processing):**
- [ ] UI accepts multiple file uploads simultaneously
- [ ] All files processed in single transcribe() call (parallel batching)
- [ ] Results show per-file statistics and transcriptions
- [ ] Progress indicator displays for multi-file jobs
- [ ] Single-file workflow unchanged

**Issue #3 (Video Support):**
- [ ] MP4, AVI, MKV, MOV, WEBM video formats accepted
- [ ] Audio automatically extracted from video files
- [ ] Status message indicates "Extracting audio from video..."
- [ ] Clear error if video has no audio track
- [ ] UI documentation updated with supported video formats

**Issue #4 (Model Caching):**
- [ ] Startup checks for cached models
- [ ] Progress bars shown during initial model downloads
- [ ] Both models pre-loaded before UI becomes interactive
- [ ] Clear status messages throughout download process
- [ ] Graceful retry on download failure

**All Issues:**
- [ ] All existing single-file audio transcription tests pass
- [ ] No new console errors or warnings
- [ ] Manual test: transcribe single audio → same results as before
- [ ] Manual test: transcribe 5 audio files → all processed correctly
- [ ] Manual test: transcribe video file → audio extracted and transcribed
- [ ] Manual test: fresh install → models download with progress shown
</acceptance_criteria>

## Supporting Context

<details>
<summary>Issue #1: GPU Optimization Research</summary>

**Mixed Precision Performance:**
- RTX 4080 has dedicated FP16 tensor cores that run 2-3x faster than FP32
- NeMo models trained with mixed precision support FP16 inference without accuracy loss
- PyTorch autocast automatically selects which operations benefit from lower precision
- Expected speedup: 1.5-2.5x for Parakeet, 1.8-3.0x for Canary

**Current Batch Size Analysis:**
- Current: 4-16 based on audio duration
- Parakeet (0.6B params): Can handle batch_size 32+ on 12GB VRAM for most audio
- Canary (2.5B params): Safer max at 16 due to larger model size
- Dynamic sizing still needed based on audio length (longer = larger batches)

**TF32 Tensor Cores:**
- Ampere architecture (RTX 4080) supports TF32 automatically for FP32 matmul
- PyTorch enables for convolutions by default but not matrix multiplication
- Enable with: `torch.backends.cuda.matmul.allow_tf32 = True`
- Provides ~1.2x speedup with negligible accuracy impact

**Pin Memory:**
- Benefits only realized when using num_workers > 0 in DataLoader
- NeMo's transcribe() uses internal DataLoader
- May not provide significant benefit for single-file processing
- More beneficial if implementing custom batching for multi-file
</details>

<details>
<summary>Issue #2: Batch Processing Implementation</summary>

**Gradio Multi-File Configuration:**
```python
audio_input = gr.Audio(
    sources=["upload"],
    type="filepath",
    file_count="multiple",  # NEW: enables multi-file
    label="Audio Files"
)
```

**NeMo Multi-File Transcription:**
NeMo's transcribe() method accepts list of paths:
```python
result = model.transcribe(
    [file1, file2, file3],  # list of paths
    batch_size=batch_size,
    num_workers=4,
    timestamps=include_timestamps
)
```

**Return Type Handling:**
- Single file: `result[0].text`
- Multiple files: iterate through `result` list, each element has `.text` attribute
- Aggregate statistics: combine processing times, word counts, etc.
</details>

<details>
<summary>Issue #3: Video Format Support</summary>

**Librosa Video Handling:**
Librosa already supports video files via audioread backend:
```python
import librosa
# Works for both audio AND video files
duration = librosa.get_duration(path=video_file)
```

**Supported Video Formats:**
- MP4 (H.264, H.265, VP9)
- AVI (various codecs)
- MKV (Matroska container)
- MOV (QuickTime)
- WEBM (VP8, VP9)
- FLV (Flash Video)

**FFmpeg Dependency:**
Librosa requires FFmpeg for video file support. FFmpeg must be installed on system and available in PATH. If missing, librosa falls back to audioread which provides error message.

**Implementation Pattern:**
```python
VIDEO_EXTENSIONS = {'.mp4', '.avi', '.mkv', '.mov', '.webm', '.flv', '.m4v'}
file_ext = os.path.splitext(audio_file)[1].lower()
is_video = file_ext in VIDEO_EXTENSIONS
if is_video:
    status = "🎬 Extracting audio from video..."
```
</details>

<details>
<summary>Issue #4: Model Cache Architecture</summary>

**HuggingFace Cache Locations:**
- Linux/Mac: `~/.cache/huggingface/hub/`
- Windows: `C:\Users\username\.cache\huggingface\hub\`

**Cache Check Pattern:**
```python
from pathlib import Path
import os

def check_model_cached(model_name):
    cache_dir = os.environ.get('HF_HUB_CACHE', 
                                Path.home() / '.cache' / 'huggingface' / 'hub')
    # Check if model directory exists
    # Return True/False
```

**Download Progress Integration:**
```python
from tqdm import tqdm

# NeMo from_pretrained() uses HF hub internally
# Progress shown automatically if tqdm installed
# For custom progress, wrap in download callback
```

**Startup Sequence:**
1. Check if models cached
2. If missing, show download UI
3. Download with progress bars
4. Cache for future use
5. Load into memory
6. Launch main UI
</details>

---

**Priority:** High (Issues #1-2), Medium (Issues #3-4) | **Target:** Single coordinated PR | **Estimated Complexity:** Medium-High
