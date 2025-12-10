# Parakeet Transcription: Function Not Executing (Gradio Event Binding Issue)

**Date:** 2025-12-10 | **Scope:** Gradio button click event not triggering transcription function | **Severity:** Critical

---

## Problem Summary

The "🚀 Start Transcription" button in the Gradio UI is not triggering the `transcribe_audio()` function despite valid input files being uploaded. The screenshot shows the interface is running and the Parakeet model appears to be loading in the PowerShell terminal, but clicking the button produces no visible effect—no status update in the UI, no terminal output, and no transcription results. The button appears to be non-responsive.

## Root Cause

The issue is in the **Gradio event binding setup** at the end of `transcribe_ui.py`. The button click handler is connected to the function using incorrect method chaining that prevents proper event registration.

**File:** `transcribe_ui.py`  
**Location:** Lines 922-928 (button event connection)  
**Issue:** The button click is being bound AFTER the Gradio app context has already been finalized with the `with gr.Blocks()` context manager. Event connections made at this point may not be properly registered in the Gradio event queue or may not propagate correctly to the backend handler.

Specifically, at line 922:
```python
transcribe_btn.click(
    fn=transcribe_audio,
    inputs=[audio_input, model_selector, save_checkbox, timestamp_checkbox],
    outputs=[status_output, transcription_output, file_output]
)
```

This click handler is being registered outside the Gradio context manager block (which ends at line 920), but still within the same Python execution scope. **This creates a timing/scope issue where the Gradio event dispatcher may not properly queue or execute the callback.**

According to Gradio documentation, event listeners should ideally be registered within the `gr.Blocks()` context to ensure proper integration with the Gradio event system. While Gradio is permissive about this, the timing of when handlers are registered relative to the context manager can cause issues with callback execution in certain versions or configurations.

Additionally, the PowerShell terminal output shows the model loading successfully and the interface starting, but there are no error messages indicating a callback failure—this suggests the callback is simply not being invoked by Gradio when the button is clicked.

<scope>
**Modify:**
- `transcribe_ui.py` (event binding logic, lines 922-928)

**Do NOT Modify:**
- `transcribe_audio()` function itself (logic is correct)
- `setup_local_models.py` (no changes needed)
- Model loading code (working correctly per terminal output)
</scope>

## Fix Required

Move the button click event registration **inside the `with gr.Blocks()` context manager block**, immediately after the button definition and before the context manager closes. This ensures the event handler is registered while Gradio's event system is actively tracking component definitions and event bindings.

The fix should maintain all current inputs and outputs but establish the event binding in the proper Gradio lifecycle phase. Additionally, add `queue=True` parameter to the click event to ensure the function is queued properly by Gradio's backend task queue.

This is a structural fix rather than a logic fix—the `transcribe_audio()` function itself is correctly implemented; the issue is purely about how Gradio is being instructed to invoke it.

<acceptance_criteria>
- [ ] Button click triggers `transcribe_audio()` callback (function begins executing)
- [ ] Status updates appear in the Gradio UI within 2-3 seconds of clicking
- [ ] Terminal shows transcription progress messages ("Processing file:", "Inference Time:", etc.)
- [ ] Transcription text appears in output textbox upon completion
- [ ] File download output works when save_to_file is enabled
- [ ] Multiple file uploads and batch processing work correctly
- [ ] No console errors related to event binding or callback execution
- [ ] Manual test: Upload audio → Click button → See real-time progress → View results
</acceptance_criteria>

## Supporting Context

<details>
<summary>Why This Happens: Gradio Event System Architecture</summary>

Gradio's event system works by maintaining a registry of component definitions and their associated event handlers. When a component is created (e.g., `transcribe_btn = gr.Button(...)`), Gradio registers it in its internal state. Event handlers (e.g., `.click()`) must be registered while the context manager is active to ensure:

1. The component's event handler is added to the Gradio event queue
2. The backend server's route definitions are updated to handle the new callback
3. The frontend JavaScript properly connects the button to the callback endpoint

When events are registered outside the context manager (even in the same scope), there's a race condition where:
- The context manager finalizes the app structure
- Event handlers are added after finalization is complete
- Gradio's event dispatcher may have already sealed its routing table
- Button clicks may not find a corresponding backend handler

This is less common in newer Gradio versions due to improvements in event handling, but it's a known issue in certain configurations, particularly when:
- Multiple event handlers are chained
- The app is launched immediately after definition
- The Gradio version has specific event queue implementations

**Reference:** GitHub NeMo Issue #7953 documents a similar threading/event loop issue where model transcription calls hang when not properly invoked from the correct execution context.

</details>

<details>
<summary>Why Terminal Shows Model Loading But Button Doesn't Work</summary>

The terminal output shows:
```
✓ GPU: NVIDIA GeForce RTX 4080 Laptop GPU
✓ VRAM: 12.0 GB
✓ CUDA: 12.0
```

And then:
```
Loading Parakeet-TDT-0.6B v2 from local file...
✓ Parakeet-TDT-0.6B v2 loaded in 2.3s
```

This proves:
1. The app is running correctly
2. Model loading works
3. The transcribe_audio function would work if called

The button not triggering is purely a Gradio event binding issue—if the callback were firing, the terminal would immediately show additional output like "Processing file:", "Inference Time:", etc. The absence of any callback-related output confirms the function is never being invoked.

</details>

<details>
<summary>Diagnostic Evidence: Screenshot Analysis</summary>

The screenshot shows:
- Gradio interface loaded at http://127.0.0.1:7860 ✓
- Audio file "LibMusicVideo_mixdown.wav" successfully uploaded ✓
- Model selection set to Parakeet ✓
- Checkboxes configured ✓
- **But:** Status box still shows initial placeholder text ("Upload an audio file...") despite file being present
- **But:** No progress indicator or status updates appeared
- **But:** Terminal shows no transcription-related messages after initial setup

This pattern (file uploaded, button clicked, but no UI update and no terminal output) is textbook evidence of a callback not being invoked, not a transcription failure.

</details>

---

**Priority:** Critical | **Dependencies:** None | **Complexity:** Low (structural fix only)
