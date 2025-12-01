#NoEnv         ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance Force

; modify these if your computer is fast enough to wait less
; or so slow it needs to wait longer; times are in ms
LONG_WAIT   := 2000
MED_WAIT    := 1000
SHORT_WAIT  := 450
QUICK_WAIT  := 200

; This determines the keyboard shortcut; currently set to Ctrl + Shift + Home
^+Home::

Run, explorer.exe
WinActivate, ahk_exe explorer.exe
Sleep, LONG_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, Downloads 
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Video Specific Assets and Footage\Atrioc video\Images
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Video Specific Assets and Footage\Atrioc video\Video
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Video Specific Assets and Footage\Atrioc video\Footage and Audio Clips
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Snipping Tool and Screenshots\Screenshots
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Photoshop Folder\Final Project
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Recordings
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets\Universal Video Assets
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets\Universal Image Assets
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets\Music
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets\SFX
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky Audition Folder\Final Recordings
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load
Send ^t
Sleep, SHORT_WAIT

Send, !d ; simulate Alt+D to focus the address bar
Sleep, QUICK_WAIT
Send, E:\Chunky's Master Folder\Chunky After Effects Folder\Final Projects
Sleep, QUICK_WAIT
Send, {Enter} ; Enter to go to folder
Sleep, SHORT_WAIT ; give a moment for the folder to load



return

^+Escape::
ExitApp
Return
