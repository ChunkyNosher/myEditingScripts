; Accelerated Scrolling
; V1.3
; By BoffinbraiN
;His .exe was sketchy so here is just the bare .ahk code.

; This if statement makes the script run as admin. Without it, trying to use this script while having Task Manager (and probably any other Windows Menu active, but I haven't tested it) open causes a bug where it will make you unable to type on your keyboard even after clicking out of Task Manager until you press down RCtrl again
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#NoEnv
;#NoTrayIcon
#SingleInstance
#MaxHotkeysPerInterval 10000

Process, Priority, , H
SendMode Input

#SingleInstance force
	
; Show scroll velocity as a tooltip while scrolling. 1 or 0.
tooltips := 0

; The length of a scrolling session.
; Keep scrolling within this time to accumulate boost.
; Default: 500. Recommended between 400 and 1000.
timeout := 800

; If you scroll a long distance in one session, apply additional boost factor.
; The higher the value, the longer it takes to activate, and the slower it accumulates.
; Set to zero to disable completely. Default: 30.
boost := 40

; Spamming applications with hundreds of individual scroll events can slow them down.
; This sets the maximum number of scrolls sent per click, i.e. max velocity. Default: 60.
limit := 10000

; Runtime variables. Do not modify.
distance := 0
vmax := 1

; APPLICATIONS WHERE SCRIPT SHOULD BE DISABLED
; Use #If to conditionally disable the hotkeys for specific applications
#IfWinNotActive ahk_exe FortniteClient-Win64-Shipping.exe

; Key bindings (only active when NOT in Fortnite)
WheelUp::    Goto Scroll
WheelDown::  Goto Scroll

#IfWinNotActive  ; End the condition

; Manual suspend toggle (works in all applications)
#WheelUp::
    Suspend, Toggle
    if (A_IsSuspended)
        QuickToolTip("Accelerated Scrolling SUSPENDED", 1000)
    else
        QuickToolTip("Accelerated Scrolling ENABLED", 1000)
return

#WheelDown:: 
    ; You can add functionality here if needed, or leave empty
return

Scroll:
	t := A_TimeSincePriorHotkey
	if (A_PriorHotkey = A_ThisHotkey && t < timeout)
	{
		; Remember how many times we've scrolled in the current direction
		distance++

		; Calculate acceleration factor using a 1/x curve
		v := (t < 80 && t > 1) ? (250.0 / t) - 1 : 1

		; Apply boost
		if (boost > 1 && distance > boost)
		{
			; Hold onto the highest speed we've achieved during this boost
			if (v > vmax)
				vmax := v
			else
				v := vmax

			v *= distance / boost
		}

		; Validate
		v := (v > 1) ? ((v > limit) ? limit : Floor(v)) : 1

		if (v > 1 && tooltips)
			QuickToolTip(" "v, timeout)
		
		

		MouseClick, %A_ThisHotkey%, , , v
	}
	else
	{
		; Combo broken, so reset session variables
		distance := 0
		vmax := 1

		MouseClick %A_ThisHotkey%
	}
	return

Quit:
	QuickToolTip("Exiting Accelerated Scrolling...", 1000)
	Sleep 1000
	ExitApp

QuickToolTip(text, delay)
{
	ToolTip, %text%
	SetTimer ToolTipOff, %delay%
	return

	ToolTipOff:
	SetTimer ToolTipOff, Off
	ToolTip
	return
}