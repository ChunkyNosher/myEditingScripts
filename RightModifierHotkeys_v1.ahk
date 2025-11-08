; Custom modifier tracking system
rctrlPressed := false
raltPressed := false
rshiftPressed := false

; Track RCtrl without using GetKeyState
$RCtrl::
    rctrlPressed := true
    KeyWait, RCtrl, T2.0
    if (ErrorLevel = 0) {
        ; Released within 2 seconds - block input
        rctrlPressed := false
    } else {
        ; Held longer - wait for natural release
        KeyWait, RCtrl
        rctrlPressed := false
    }
return

; Track RAlt
$RAlt::
    raltPressed := true
    KeyWait, RAlt, T2.0
    if (ErrorLevel = 0) {
        raltPressed := false
    } else {
        KeyWait, RAlt
        raltPressed := false
    }
return

; Track RShift
$RShift::
    rshiftPressed := true
    KeyWait, RShift, T2.0
    if (ErrorLevel = 0) {
        rshiftPressed := false
    } else {
        KeyWait, RShift
        rshiftPressed := false
    }
return

; Use Input command to detect keys only when modifiers are pressed
#If rctrlPressed || raltPressed || rshiftPressed

; === NUMBER ROW ===
0::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F13}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F13}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F13}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F13}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F13}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F13}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F13}
        return
    }
return

1::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F14}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F14}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F14}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F14}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F14}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F14}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F14}
        return
    }
return

2::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F15}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F15}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F15}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F15}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F15}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F15}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F15}
        return
    }
return

3::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F16}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F16}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F16}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F16}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F16}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F16}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F16}
        return
    }
return

4::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F17}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F17}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F17}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F17}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F17}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F17}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F17}
        return
    }
return

5::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F18}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F18}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F18}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F18}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F18}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F18}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F18}
        return
    }
return

6::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F19}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F19}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F19}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F19}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F19}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F19}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F19}
        return
    }
return

7::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F20}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F20}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F20}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F20}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F20}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F20}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F20}
        return
    }
return

8::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F21}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F21}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F21}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F21}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F21}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F21}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F21}
        return
    }
return

9::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        SendInput ^!+{F22}
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        SendInput ^!{F22}
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        SendInput ^+{F22}
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        SendInput !+{F22}
        return
    } else if (rctrlPressed) { ; RCtrl only
        SendInput ^{F22}
        return
    } else if (raltPressed) { ; RAlt only
        SendInput !{F22}
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput +{F22}
        return
    }
return

; === LETTERS ===
a::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

b::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        IfWinNotExist, ahk_exe Arc.exe
        {
            Run, Arc.exe
        }
        WinActivate, ahk_exe Arc.exe
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

c::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

d::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput ^c  ; Testing function
        return
    }
return

e::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

f::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        IfWinNotExist, ahk_exe Focusrite Notifier.exe
            Run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Focusrite Drivers\Focusrite Device Settings.lnk
        WinActivate, ahk_exe Focusrite Notifier.exe
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

g::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

h::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

i::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

j::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

k::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

l::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

m::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        IfWinNotExist, ahk_class CabinetWClass
            SendInput, ^+Home
        GroupAdd, ChunkyFiles, ahk_class CabinetWClass
        if WinActive("ahk_exe explorer.exe")
            GroupActivate, ChunkyFiles, r
        else
            WinActivate ahk_class CabinetWClass
        return 
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

n::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        IfWinNotExist, ahk_exe Adobe Premiere Pro.exe
        {
            Run, Adobe Premiere Pro.exe
        }
        WinActivate, ahk_exe Adobe Premiere Pro.exe
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        return 
    }
return

o::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

p::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

q::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

r::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

s::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

t::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

u::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

v::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

w::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

x::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

y::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

z::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; === FUNCTION KEYS ===
F1::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F2::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F3::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F4::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F5::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F6::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F7::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F8::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F9::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F10::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F11::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

F12::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; === SYMBOLS ===
; Semicolon
$;::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Comma
$,::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Period
$.::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Forward Slash
$/::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Left Bracket
$[::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Right Bracket
$]::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Backslash
$\::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return 

; Apostrophe - needs special handling
SC028::  ; Use the scan code for apostrophe instead of the character
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        SendInput ^x
        return
    }
return

; Dash/Minus
$-::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Equals
$=::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Backtick/Grave
$`::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; === NAVIGATION KEYS ===
; Arrow Up
Up::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Arrow Down
Down::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Arrow Left
Left::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Arrow Right
Right::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Home
Home::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; End
End::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Page Up
PgUp::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Page Down
PgDn::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Insert
Insert::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Delete
Del::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; === NUMPAD KEYS ===
; Numpad 0
Numpad0::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 1
Numpad1::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 2
Numpad2::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 3
Numpad3::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 4
Numpad4::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 5
Numpad5::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 6
Numpad6::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 7
Numpad7::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 8
Numpad8::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad 9
Numpad9::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Dot
NumpadDot::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Enter
NumpadEnter::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Add
NumpadAdd::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Subtract
NumpadSub::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Multiply
NumpadMult::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

; Numpad Divide
NumpadDiv::
    if (rctrlPressed && raltPressed && rshiftPressed) { ; RCtrl + RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed && raltPressed) { ; RCtrl + RAlt
        ; Add your hotkey here
        return
    } else if (rctrlPressed && rshiftPressed) { ; RCtrl + RShift
        ; Add your hotkey here
        return
    } else if (raltPressed && rshiftPressed) { ; RAlt + RShift
        ; Add your hotkey here
        return
    } else if (rctrlPressed) { ; RCtrl only
        ; Add your hotkey here
        return
    } else if (raltPressed) { ; RAlt only
        ; Add your hotkey here
        return
    } else if (rshiftPressed) { ; RShift only
        ; Add your hotkey here
        return
    }
return

#If