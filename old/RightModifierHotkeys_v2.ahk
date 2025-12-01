; Custom modifier tracking system
global rctrlPressed := false
global raltPressed := false
global rshiftPressed := false

; Hotkey configuration array
; Format: [RCtrl, RAlt, RShift, RCtrl+RAlt, RCtrl+RShift, RAlt+RShift, RCtrl+RAlt+RShift]
; Use function names for complex actions, SendInput strings for key commands
global HotkeyConfig := {}

; === NUMBER ROW ===
HotkeyConfig["SC002"] := ["^{F14}", "!{F14}", "+{F14}", "^!{F14}", "^+{F14}", "!+{F14}", "^!+{F14}"] ; "1"
HotkeyConfig["SC003"] := ["^{F15}", "!{F15}", "+{F15}", "^!{F15}", "^+{F15}", "!+{F15}", "^!+{F15}"] ; "2"
HotkeyConfig["SC004"] := ["^{F16}", "!{F16}", "+{F16}", "^!{F16}", "^+{F16}", "!+{F16}", "^!+{F16}"] ; "3"
HotkeyConfig["SC005"] := ["^{F17}", "!{F17}", "+{F17}", "^!{F17}", "^+{F17}", "!+{F17}", "^!+{F17}"] ; "4"
HotkeyConfig["SC006"] := ["^{F18}", "!{F18}", "+{F18}", "^!{F18}", "^+{F18}", "!+{F18}", "^!+{F18}"] ; "5"
HotkeyConfig["SC007"] := ["^{F19}", "!{F19}", "+{F19}", "^!{F19}", "^+{F19}", "!+{F19}", "^!+{F19}"] ; "6"
HotkeyConfig["SC008"] := ["^{F20}", "!{F20}", "+{F20}", "^!{F20}", "^+{F20}", "!+{F20}", "^!+{F20}"] ; "7"
HotkeyConfig["SC009"] := ["^{F21}", "!{F21}", "+{F21}", "^!{F21}", "^+{F21}", "!+{F21}", "^!+{F21}"] ; "8"
HotkeyConfig["SC00A"] := ["^{F22}", "!{F22}", "+{F22}", "^!{F22}", "^+{F22}", "!+{F22}", "^!+{F22}"] ; "9"
HotkeyConfig["SC00B"] := ["^{F13}", "!{F13}", "+{F13}", "^!{F13}", "^+{F13}", "!+{F13}", "^!+{F13}"] ; "0"

; === LETTERS ===
HotkeyConfig["SC01E"] := ["", "", "", "", "", "", ""] ; "a"
HotkeyConfig["SC030"] := ["LaunchArc", "", "", "", "", "", ""] ; "b"
HotkeyConfig["SC02E"] := ["", "", "", "", "", "", ""] ; "c"
HotkeyConfig["SC020"] := ["", "", "^c", "", "", "", ""] ; "d"
HotkeyConfig["SC012"] := ["", "", "", "", "", "", ""] ; "e"
HotkeyConfig["SC021"] := ["LaunchFocusrite", "", "", "", "", "", ""] ; "f"
HotkeyConfig["SC022"] := ["", "", "", "", "", "", ""] ; "g"
HotkeyConfig["SC023"] := ["", "", "", "", "", "", ""] ; "h"
HotkeyConfig["SC017"] := ["", "", "", "", "", "", ""] ; "i"
HotkeyConfig["SC024"] := ["", "", "", "", "", "", ""] ; "j"
HotkeyConfig["SC025"] := ["", "", "", "", "", "", ""] ; "k"
HotkeyConfig["SC026"] := ["", "", "", "", "", "", ""] ; "l"
HotkeyConfig["SC032"] := ["ActivateExplorer", "", "", "", "", "", ""] ; "m"
HotkeyConfig["SC031"] := ["LaunchPremiere", "", "", "", "", "", ""] ; "n"
HotkeyConfig["SC018"] := ["", "", "", "", "", "", ""] ; "o"
HotkeyConfig["SC019"] := ["", "", "", "", "", "", ""] ; "p"
HotkeyConfig["SC010"] := ["", "", "", "", "", "", ""] ; "q"
HotkeyConfig["SC013"] := ["", "", "", "", "", "", ""] ; "r"
HotkeyConfig["SC01F"] := ["", "", "", "", "", "", ""] ; "s"
HotkeyConfig["SC014"] := ["", "", "", "", "", "", ""] ; "t"
HotkeyConfig["SC016"] := ["", "", "", "", "", "", ""] ; "u"
HotkeyConfig["SC02F"] := ["", "", "", "", "", "", ""] ; "v"
HotkeyConfig["SC011"] := ["", "", "", "", "", "", ""] ; "w"
HotkeyConfig["SC02D"] := ["", "", "", "", "", "", ""] ; "x"
HotkeyConfig["SC015"] := ["", "", "", "", "", "", ""] ; "y"
HotkeyConfig["SC02C"] := ["", "", "", "", "", "", ""] ; "z"

; === FUNCTION KEYS ===
HotkeyConfig["SC03B"] := ["", "", "", "", "", "", ""] ; "F1"
HotkeyConfig["SC03C"] := ["", "", "", "", "", "", ""] ; "F2"
HotkeyConfig["SC03D"] := ["", "", "", "", "", "", ""] ; "F3"
HotkeyConfig["SC03E"] := ["", "", "", "", "", "", ""] ; "F4"
HotkeyConfig["SC03F"] := ["", "", "", "", "", "", ""] ; "F5"
HotkeyConfig["SC040"] := ["", "", "", "", "", "", ""] ; "F6"
HotkeyConfig["SC041"] := ["", "", "", "", "", "", ""] ; "F7"
HotkeyConfig["SC042"] := ["", "", "", "", "", "", ""] ; "F8"
HotkeyConfig["SC043"] := ["", "", "", "", "", "", ""] ; "F9"
HotkeyConfig["SC044"] := ["", "", "", "", "", "", ""] ; "F10"
HotkeyConfig["SC057"] := ["", "", "", "", "", "", ""] ; "F11"
HotkeyConfig["SC058"] := ["", "", "", "", "", "", ""] ; "F12"

; === SYMBOLS ===
HotkeyConfig["SC027"] := ["", "", "", "", "", "", ""] ; ";"
HotkeyConfig["SC033"] := ["", "", "", "", "", "", ""] ; ","
HotkeyConfig["SC034"] := ["", "", "", "", "", "", ""] ; "."
HotkeyConfig["SC035"] := ["", "", "", "", "", "", ""] ; "/"
HotkeyConfig["SC01A"] := ["", "", "", "", "", "", ""] ; "["
HotkeyConfig["SC01B"] := ["", "", "", "", "", "", ""] ; "]"
HotkeyConfig["SC02B"] := ["", "", "", "", "", "", ""] ; "\"
HotkeyConfig["SC028"] := ["", "", "^x", "", "", "", ""] ; "'"
HotkeyConfig["SC00C"] := ["", "", "", "", "", "", ""] ; "-"
HotkeyConfig["SC00D"] := ["", "", "", "", "", "", ""] ; "="
HotkeyConfig["SC029"] := ["", "", "", "", "", "", ""] ; "`"

; === NAVIGATION KEYS ===
HotkeyConfig["SC148"] := ["", "", "", "", "", "", ""] ; "Up"
HotkeyConfig["SC150"] := ["", "", "", "", "", "", ""] ; "Down"
HotkeyConfig["SC14B"] := ["", "", "", "", "", "", ""] ; "Left"
HotkeyConfig["SC14D"] := ["", "", "", "", "", "", ""] ; "Right"
HotkeyConfig["SC147"] := ["", "", "", "", "", "", ""] ; "Home"
HotkeyConfig["SC14F"] := ["", "", "", "", "", "", ""] ; "End"
HotkeyConfig["SC149"] := ["", "", "", "", "", "", ""] ; "PgUp"
HotkeyConfig["SC151"] := ["", "", "", "", "", "", ""] ; "PgDn"
HotkeyConfig["SC152"] := ["", "", "", "", "", "", ""] ; "Insert"
HotkeyConfig["SC153"] := ["", "", "", "", "", "", ""] ; "Delete"

; === NUMPAD KEYS ===
HotkeyConfig["SC052"] := ["", "", "", "", "", "", ""] ; "Numpad0"
HotkeyConfig["SC04F"] := ["", "", "", "", "", "", ""] ; "Numpad1"
HotkeyConfig["SC050"] := ["", "", "", "", "", "", ""] ; "Numpad2"
HotkeyConfig["SC051"] := ["", "", "", "", "", "", ""] ; "Numpad3"
HotkeyConfig["SC04B"] := ["", "", "", "", "", "", ""] ; "Numpad4"
HotkeyConfig["SC04C"] := ["", "", "", "", "", "", ""] ; "Numpad5"
HotkeyConfig["SC04D"] := ["", "", "", "", "", "", ""] ; "Numpad6"
HotkeyConfig["SC047"] := ["", "", "", "", "", "", ""] ; "Numpad7"
HotkeyConfig["SC048"] := ["", "", "", "", "", "", ""] ; "Numpad8"
HotkeyConfig["SC049"] := ["", "", "", "", "", "", ""] ; "Numpad9"
HotkeyConfig["SC053"] := ["", "", "", "", "", "", ""] ; "NumpadDot"
HotkeyConfig["NumpadEnter"] := ["", "", "", "", "", "", ""] ; "NumpadEnter"
HotkeyConfig["SC04E"] := ["", "", "", "", "", "", ""] ; "NumpadAdd"
HotkeyConfig["SC04A"] := ["", "", "", "", "", "", ""] ; "NumpadSub"
HotkeyConfig["SC037"] := ["", "", "", "", "", "", ""] ; "NumpadMult"
HotkeyConfig["NumpadDiv"] := ["", "", "", "", "", "", ""] ; "NumpadDiv"

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

; Function to handle hotkey execution using Method 4 detection
HandleHotkey(key) {
    global rctrlPressed, raltPressed, rshiftPressed, HotkeyConfig
    
    ; Get the configuration for this key
    config := HotkeyConfig[key]
    if (!IsObject(config)) {
        return ; No configuration for this key
    }
    
    ; Determine which modifier combination is pressed and get the action
    action := ""
    if (rctrlPressed && raltPressed && rshiftPressed) {
        action := config[7]
    } else if (rctrlPressed && raltPressed) {
        action := config[4]
    } else if (rctrlPressed && rshiftPressed) {
        action := config[5]
    } else if (raltPressed && rshiftPressed) {
        action := config[6]
    } else if (rctrlPressed) {
        action := config[1]
    } else if (raltPressed) {
        action := config[2]
    } else if (rshiftPressed) {
        action := config[3]
    }
    
    ; Execute the action if one is defined
    if (action != "") {
        ; Method 4: Check if it's a valid function first
        if (IsFunc(action)) {
            ; It's a function - call it
            %action%()
        } else {
            ; Not a function - assume it's a SendInput command
            SendInput, %action%
        }
    }
}

; =============================================
; CUSTOM ACTION FUNCTIONS
; =============================================

LaunchArc() {
    IfWinNotExist, ahk_exe Arc.exe
        Run, Arc.exe
    WinActivate, ahk_exe Arc.exe
}

LaunchFocusrite() {
    IfWinNotExist, ahk_exe Focusrite Notifier.exe
        Run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Focusrite Drivers\Focusrite Device Settings.lnk
    WinActivate, ahk_exe Focusrite Notifier.exe
}

ActivateExplorer() {
    IfWinNotExist, ahk_class CabinetWClass
        SendInput ^+Home
    GroupAdd, ChunkyFiles, ahk_class CabinetWClass
    if WinActive("ahk_exe explorer.exe")
        GroupActivate, ChunkyFiles, r
    else
        WinActivate ahk_class CabinetWClass
}

LaunchPremiere() {
    IfWinNotExist, ahk_exe Adobe Premiere Pro.exe
        Run, Adobe Premiere Pro.exe
    WinActivate, ahk_exe Adobe Premiere Pro.exe
}

; Use Input command to detect keys only when modifiers are pressed
#If rctrlPressed || raltPressed || rshiftPressed

; === NUMBER ROW ===
SC002:: HandleHotkey("SC002") ; "1"
SC003:: HandleHotkey("SC003") ; "2"
SC004:: HandleHotkey("SC004") ; "3"
SC005:: HandleHotkey("SC005") ; "4"
SC006:: HandleHotkey("SC006") ; "5"
SC007:: HandleHotkey("SC007") ; "6"
SC008:: HandleHotkey("SC008") ; "7"
SC009:: HandleHotkey("SC009") ; "8"
SC00A:: HandleHotkey("SC00A") ; "9"
SC00B:: HandleHotkey("SC00B") ; "0"

; === LETTERS ===
SC01E:: HandleHotkey("SC01E") ; "a"
SC030:: HandleHotkey("SC030") ; "b"
SC02E:: HandleHotkey("SC02E") ; "c"
SC020:: HandleHotkey("SC020") ; "d"
SC012:: HandleHotkey("SC012") ; "e"
SC021:: HandleHotkey("SC021") ; "f"
SC022:: HandleHotkey("SC022") ; "g"
SC023:: HandleHotkey("SC023") ; "h"
SC017:: HandleHotkey("SC017") ; "i"
SC024:: HandleHotkey("SC024") ; "j"
SC025:: HandleHotkey("SC025") ; "k"
SC026:: HandleHotkey("SC026") ; "l"
SC032:: HandleHotkey("SC032") ; "m"
SC031:: HandleHotkey("SC031") ; "n"
SC018:: HandleHotkey("SC018") ; "o"
SC019:: HandleHotkey("SC019") ; "p"
SC010:: HandleHotkey("SC010") ; "q"
SC013:: HandleHotkey("SC013") ; "r"
SC01F:: HandleHotkey("SC01F") ; "s"
SC014:: HandleHotkey("SC014") ; "t"
SC016:: HandleHotkey("SC016") ; "u"
SC02F:: HandleHotkey("SC02F") ; "v"
SC011:: HandleHotkey("SC011") ; "w"
SC02D:: HandleHotkey("SC02D") ; "x"
SC015:: HandleHotkey("SC015") ; "y"
SC02C:: HandleHotkey("SC02C") ; "z"

; === FUNCTION KEYS ===
SC03B:: HandleHotkey("SC03B") ; "F1"
SC03C:: HandleHotkey("SC03C") ; "F2"
SC03D:: HandleHotkey("SC03D") ; "F3"
SC03E:: HandleHotkey("SC03E") ; "F4"
SC03F:: HandleHotkey("SC03F") ; "F5"
SC040:: HandleHotkey("SC040") ; "F6"
SC041:: HandleHotkey("SC041") ; "F7"
SC042:: HandleHotkey("SC042") ; "F8"
SC043:: HandleHotkey("SC043") ; "F9"
SC044:: HandleHotkey("SC044") ; "F10"
SC057:: HandleHotkey("SC057") ; "F11"
SC058:: HandleHotkey("SC058") ; "F12"

; === SYMBOLS ===
SC027:: HandleHotkey("SC027") ; ";"
SC033:: HandleHotkey("SC033") ; ","
SC034:: HandleHotkey("SC034") ; "."
SC035:: HandleHotkey("SC035") ; "/"
SC01A:: HandleHotkey("SC01A") ; "["
SC01B:: HandleHotkey("SC01B") ; "]"
SC02B:: HandleHotkey("SC02B") ; "\"
SC028:: HandleHotkey("SC028") ; "'"
SC00C:: HandleHotkey("SC00C") ; "-"
SC00D:: HandleHotkey("SC00D") ; "="
SC029:: HandleHotkey("SC029") ; "`"

; === NAVIGATION KEYS ===
SC148:: HandleHotkey("SC148") ; "Up"
SC150:: HandleHotkey("SC150") ; "Down"
SC14B:: HandleHotkey("SC14B") ; "Left"
SC14D:: HandleHotkey("SC14D") ; "Right"
SC147:: HandleHotkey("SC147") ; "Home"
SC14F:: HandleHotkey("SC14F") ; "End"
SC149:: HandleHotkey("SC149") ; "PgUp"
SC151:: HandleHotkey("SC151") ; "PgDn"
SC152:: HandleHotkey("SC152") ; "Insert"
SC153:: HandleHotkey("SC153") ; "Delete"

; === NUMPAD KEYS ===
SC052:: HandleHotkey("SC052") ; "Numpad0"
SC04F:: HandleHotkey("SC04F") ; "Numpad1"
SC050:: HandleHotkey("SC050") ; "Numpad2"
SC051:: HandleHotkey("SC051") ; "Numpad3"
SC04B:: HandleHotkey("SC04B") ; "Numpad4"
SC04C:: HandleHotkey("SC04C") ; "Numpad5"
SC04D:: HandleHotkey("SC04D") ; "Numpad6"
SC047:: HandleHotkey("SC047") ; "Numpad7"
SC048:: HandleHotkey("SC048") ; "Numpad8"
SC049:: HandleHotkey("SC049") ; "Numpad9"
SC053:: HandleHotkey("SC053") ; "NumpadDot"
NumpadEnter:: HandleHotkey("NumpadEnter") ; "NumpadEnter"
SC04E:: HandleHotkey("SC04E") ; "NumpadAdd"
SC04A:: HandleHotkey("SC04A") ; "NumpadSub"
SC037:: HandleHotkey("SC037") ; "NumpadMult"
NumpadDiv:: HandleHotkey("NumpadDiv") ; "NumpadDiv"

#If
