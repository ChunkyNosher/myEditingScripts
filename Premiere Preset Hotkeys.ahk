#IfWinActive ahk_exe Adobe Premiere Pro.exe
#SingleInstance Force

CoordMode, Mouse, Screen
CoordMode, Caret, Screen

; Emergency suspend shortcut - Ctrl+Alt+Shift+Esc
^!+Esc::Suspend, Toggle

; Caret detection loop (unchanged from original, kept outside function)
if (A_CaretX = "")
{
;No Caret (blinking vertical line) can be found.

;The following loop is waiting until it sees the caret. THIS IS SUPER IMPORTANT, because Premiere is sometimes quite slow to actually select the find box, and if the function tries to proceed before that has happened, it will fail. This would happen to me about 10% of the time.
;Using the loop is also way better than just ALWAYS waiting 60 milliseconds like I was before. With the loop, this function can continue as soon as Premiere is ready.

;sleep 60 ;<—Use this line if you don't want to use the loop below. But the loop should work perfectly fine as-is, without any modification from you.
;Copy and pasted from Taran's github

waiting2 = 0
loop
	{
	waiting2 ++
	sleep 33
	if (A_CaretX <> "")
		{
		tooltip, CARET WAS FOUND
		break
		}
	if (waiting2 > 40)
		{
		;Note to self, need much better way to debug this than screwing the user. As it stands, that tooltip will stay there forever.
		;USER: Running the function again, or reloading the script, will remove that tooltip.
		;sleep 200
		;tooltip,
		sleep 20
		GOTO theEnding
		}
	}
sleep 1
tooltip,
}

theEnding:
return

; Function with exact lines from original hotkey
ApplySlidePreset(presetName) {
    BlockInput, SendAndMouse
    BlockInput, MouseMove
    BlockInput, On
    MouseGetPos, OrigX, OrigY ; gets position of mouse cursor when hovered over a clip
    Send, ^+E ; selects effects panel
    Send ^!+F
    Send {BS}
    SendInput %presetName% ; Put name of preset here
    MouseMove, A_CaretX, A_CaretY ; moves mouse cursor to search box
    MouseMove, 41, 63, 0, R
    MouseGetPos, FX_X, FX_Y ; gets position of mouse cursor when hovered over preset
    MouseClickDrag, L, FX_X, FX_Y, OrigX, OrigY, 0
    BlockInput, MouseMoveOff 
    BlockInput, off 
    return
}

; Hotkey assignments
^!F1::ApplySlidePreset("Slide in from left")
^+F1::ApplySlidePreset("Slide in from right") 
^!+F1::ApplySlidePreset("Slide in from top")
!+F1::ApplySlidePreset("Slide in from bottom")

; Functions for each preset

SlideInFromLeft() {
	ApplySlidePreset("Slide in from left")
}
SlideInFromRight() {
	ApplySlidePreset("Slide in from right") 
}
SlideInFromTop() {
	ApplySlidePreset("Slide in from top")
}
SlideInFromBottom() {
	ApplySlidePreset("Slide in from bottom")
}
