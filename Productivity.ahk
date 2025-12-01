#NoEnv
#SingleInstance force


;------ Quick Voice Recording Keys, Loop must be off

#ifwinactive ahk_exe Adobe Audition.exe

F2:: 
Send {Space}
Return

F3:: 
Send {Space}
Send +{Space}
Return

F1::
Send {Space}
Send ^z
Send ^f
Return

F4::
Send {Space}
Send !+{Space}