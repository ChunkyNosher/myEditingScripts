if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}
; Custom modifier tracking system
global rctrlPressed := false
global raltPressed := false
global rshiftPressed := false

; =============================================
; MODIFIER CONSTANTS FOR READABLE CONFIG
; =============================================
global MOD_RCTRL := 1
global MOD_RALT := 2
global MOD_RSHIFT := 3
global MOD_RCTRL_RALT := 4
global MOD_RCTRL_RSHIFT := 5
global MOD_RALT_RSHIFT := 6
global MOD_RCTRL_RALT_RSHIFT := 7

global HotkeyConfig := {}

; === NUMBER ROW ===
HotkeyConfig["SC002"] := [] ; "1"
HotkeyConfig["SC002"][MOD_RCTRL] := "^{F14}"
HotkeyConfig["SC002"][MOD_RALT] := "!{F14}"
HotkeyConfig["SC002"][MOD_RSHIFT] := "+{F14}"
HotkeyConfig["SC002"][MOD_RCTRL_RALT] := "^!{F14}"
HotkeyConfig["SC002"][MOD_RCTRL_RSHIFT] := "^+{F14}"
HotkeyConfig["SC002"][MOD_RALT_RSHIFT] := "!+{F14}"
HotkeyConfig["SC002"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F14}"

HotkeyConfig["SC003"] := [] ; "2"
HotkeyConfig["SC003"][MOD_RCTRL] := "^{F15}"
HotkeyConfig["SC003"][MOD_RALT] := "!{F15}"
HotkeyConfig["SC003"][MOD_RSHIFT] := "+{F15}"
HotkeyConfig["SC003"][MOD_RCTRL_RALT] := "^!{F15}"
HotkeyConfig["SC003"][MOD_RCTRL_RSHIFT] := "^+{F15}"
HotkeyConfig["SC003"][MOD_RALT_RSHIFT] := "!+{F15}"
HotkeyConfig["SC003"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F15}"

HotkeyConfig["SC004"] := [] ; "3"
HotkeyConfig["SC004"][MOD_RCTRL] := "^{F16}"
HotkeyConfig["SC004"][MOD_RALT] := "!{F16}"
HotkeyConfig["SC004"][MOD_RSHIFT] := "+{F16}"
HotkeyConfig["SC004"][MOD_RCTRL_RALT] := "^!{F16}"
HotkeyConfig["SC004"][MOD_RCTRL_RSHIFT] := "^+{F16}"
HotkeyConfig["SC004"][MOD_RALT_RSHIFT] := "!+{F16}"
HotkeyConfig["SC004"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F16}"

HotkeyConfig["SC005"] := [] ; "4"
HotkeyConfig["SC005"][MOD_RCTRL] := "^{F17}"
HotkeyConfig["SC005"][MOD_RALT] := "!{F17}"
HotkeyConfig["SC005"][MOD_RSHIFT] := "+{F17}"
HotkeyConfig["SC005"][MOD_RCTRL_RALT] := "^!{F17}"
HotkeyConfig["SC005"][MOD_RCTRL_RSHIFT] := "^+{F17}"
HotkeyConfig["SC005"][MOD_RALT_RSHIFT] := "!+{F17}"
HotkeyConfig["SC005"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F17}"

HotkeyConfig["SC006"] := [] ; "5"
HotkeyConfig["SC006"][MOD_RCTRL] := "^{F18}"
HotkeyConfig["SC006"][MOD_RALT] := "!{F18}"
HotkeyConfig["SC006"][MOD_RSHIFT] := "+{F18}"
HotkeyConfig["SC006"][MOD_RCTRL_RALT] := "^!{F18}"
HotkeyConfig["SC006"][MOD_RCTRL_RSHIFT] := "^+{F18}"
HotkeyConfig["SC006"][MOD_RALT_RSHIFT] := "!+{F18}"
HotkeyConfig["SC006"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F18}"

HotkeyConfig["SC007"] := [] ; "6"
HotkeyConfig["SC007"][MOD_RCTRL] := "^{F19}"
HotkeyConfig["SC007"][MOD_RALT] := "!{F19}"
HotkeyConfig["SC007"][MOD_RSHIFT] := "+{F19}"
HotkeyConfig["SC007"][MOD_RCTRL_RALT] := "^!{F19}"
HotkeyConfig["SC007"][MOD_RCTRL_RSHIFT] := "^+{F19}"
HotkeyConfig["SC007"][MOD_RALT_RSHIFT] := "!+{F19}"
HotkeyConfig["SC007"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F19}"

HotkeyConfig["SC008"] := [] ; "7"
HotkeyConfig["SC008"][MOD_RCTRL] := "^{F20}"
HotkeyConfig["SC008"][MOD_RALT] := "!{F20}"
HotkeyConfig["SC008"][MOD_RSHIFT] := "+{F20}"
HotkeyConfig["SC008"][MOD_RCTRL_RALT] := "^!{F20}"
HotkeyConfig["SC008"][MOD_RCTRL_RSHIFT] := "^+{F20}"
HotkeyConfig["SC008"][MOD_RALT_RSHIFT] := "!+{F20}"
HotkeyConfig["SC008"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F20}"

HotkeyConfig["SC009"] := [] ; "8"
HotkeyConfig["SC009"][MOD_RCTRL] := "^{F21}"
HotkeyConfig["SC009"][MOD_RALT] := "!{F21}"
HotkeyConfig["SC009"][MOD_RSHIFT] := "+{F21}"
HotkeyConfig["SC009"][MOD_RCTRL_RALT] := "^!{F21}"
HotkeyConfig["SC009"][MOD_RCTRL_RSHIFT] := "^+{F21}"
HotkeyConfig["SC009"][MOD_RALT_RSHIFT] := "!+{F21}"
HotkeyConfig["SC009"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F21}"

HotkeyConfig["SC00A"] := [] ; "9"
HotkeyConfig["SC00A"][MOD_RCTRL] := "^{F22}"
HotkeyConfig["SC00A"][MOD_RALT] := "!{F22}"
HotkeyConfig["SC00A"][MOD_RSHIFT] := "+{F22}"
HotkeyConfig["SC00A"][MOD_RCTRL_RALT] := "^!{F22}"
HotkeyConfig["SC00A"][MOD_RCTRL_RSHIFT] := "^+{F22}"
HotkeyConfig["SC00A"][MOD_RALT_RSHIFT] := "!+{F22}"
HotkeyConfig["SC00A"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F22}"

HotkeyConfig["SC00B"] := [] ; "0"
HotkeyConfig["SC00B"][MOD_RCTRL] := "^{F13}"
HotkeyConfig["SC00B"][MOD_RALT] := "!{F13}"
HotkeyConfig["SC00B"][MOD_RSHIFT] := "+{F13}"
HotkeyConfig["SC00B"][MOD_RCTRL_RALT] := "^!{F13}"
HotkeyConfig["SC00B"][MOD_RCTRL_RSHIFT] := "^+{F13}"
HotkeyConfig["SC00B"][MOD_RALT_RSHIFT] := "!+{F13}"
HotkeyConfig["SC00B"][MOD_RCTRL_RALT_RSHIFT] := "^!+{F13}"

; === LETTERS ===
HotkeyConfig["SC01E"] := [] ; "a"
HotkeyConfig["SC01E"][MOD_RCTRL] := ""
HotkeyConfig["SC01E"][MOD_RALT] := ""
HotkeyConfig["SC01E"][MOD_RSHIFT] := ""
HotkeyConfig["SC01E"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC01E"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC01E"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC01E"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC030"] := [] ; "b"
HotkeyConfig["SC030"][MOD_RCTRL] := "LaunchArc"
HotkeyConfig["SC030"][MOD_RALT] := ""
HotkeyConfig["SC030"][MOD_RSHIFT] := ""
HotkeyConfig["SC030"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC030"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC030"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC030"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC02E"] := [] ; "c"
HotkeyConfig["SC02E"][MOD_RCTRL] := ""
HotkeyConfig["SC02E"][MOD_RALT] := ""
HotkeyConfig["SC02E"][MOD_RSHIFT] := ""
HotkeyConfig["SC02E"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC02E"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC02E"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC02E"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC020"] := [] ; "d"
HotkeyConfig["SC020"][MOD_RCTRL] := ""
HotkeyConfig["SC020"][MOD_RALT] := ""
HotkeyConfig["SC020"][MOD_RSHIFT] := "^c"
HotkeyConfig["SC020"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC020"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC020"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC020"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC012"] := [] ; "e"
HotkeyConfig["SC012"][MOD_RCTRL] := ""
HotkeyConfig["SC012"][MOD_RALT] := ""
HotkeyConfig["SC012"][MOD_RSHIFT] := ""
HotkeyConfig["SC012"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC012"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC012"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC012"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC021"] := [] ; "f"
HotkeyConfig["SC021"][MOD_RCTRL] := "LaunchFocusrite"
HotkeyConfig["SC021"][MOD_RALT] := ""
HotkeyConfig["SC021"][MOD_RSHIFT] := ""
HotkeyConfig["SC021"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC021"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC021"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC021"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC022"] := [] ; "g"
HotkeyConfig["SC022"][MOD_RCTRL] := ""
HotkeyConfig["SC022"][MOD_RALT] := ""
HotkeyConfig["SC022"][MOD_RSHIFT] := ""
HotkeyConfig["SC022"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC022"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC022"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC022"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC023"] := [] ; "h"
HotkeyConfig["SC023"][MOD_RCTRL] := ""
HotkeyConfig["SC023"][MOD_RALT] := ""
HotkeyConfig["SC023"][MOD_RSHIFT] := ""
HotkeyConfig["SC023"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC023"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC023"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC023"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC017"] := [] ; "i"
HotkeyConfig["SC017"][MOD_RCTRL] := ""
HotkeyConfig["SC017"][MOD_RALT] := ""
HotkeyConfig["SC017"][MOD_RSHIFT] := ""
HotkeyConfig["SC017"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC017"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC017"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC017"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC024"] := [] ; "j"
HotkeyConfig["SC024"][MOD_RCTRL] := ""
HotkeyConfig["SC024"][MOD_RALT] := ""
HotkeyConfig["SC024"][MOD_RSHIFT] := ""
HotkeyConfig["SC024"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC024"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC024"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC024"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC025"] := [] ; "k"
HotkeyConfig["SC025"][MOD_RCTRL] := ""
HotkeyConfig["SC025"][MOD_RALT] := ""
HotkeyConfig["SC025"][MOD_RSHIFT] := ""
HotkeyConfig["SC025"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC025"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC025"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC025"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC026"] := [] ; "l"
HotkeyConfig["SC026"][MOD_RCTRL] := ""
HotkeyConfig["SC026"][MOD_RALT] := ""
HotkeyConfig["SC026"][MOD_RSHIFT] := ""
HotkeyConfig["SC026"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC026"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC026"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC026"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC032"] := [] ; "m"
HotkeyConfig["SC032"][MOD_RCTRL] := "ActivateExplorer"
HotkeyConfig["SC032"][MOD_RALT] := ""
HotkeyConfig["SC032"][MOD_RSHIFT] := ""
HotkeyConfig["SC032"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC032"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC032"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC032"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC031"] := [] ; "n"
HotkeyConfig["SC031"][MOD_RCTRL] := "LaunchPremiere"
HotkeyConfig["SC031"][MOD_RALT] := ""
HotkeyConfig["SC031"][MOD_RSHIFT] := ""
HotkeyConfig["SC031"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC031"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC031"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC031"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC018"] := [] ; "o"
HotkeyConfig["SC018"][MOD_RCTRL] := ""
HotkeyConfig["SC018"][MOD_RALT] := ""
HotkeyConfig["SC018"][MOD_RSHIFT] := ""
HotkeyConfig["SC018"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC018"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC018"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC018"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC019"] := [] ; "p"
HotkeyConfig["SC019"][MOD_RCTRL] := ""
HotkeyConfig["SC019"][MOD_RALT] := ""
HotkeyConfig["SC019"][MOD_RSHIFT] := ""
HotkeyConfig["SC019"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC019"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC019"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC019"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC010"] := [] ; "q"
HotkeyConfig["SC010"][MOD_RCTRL] := ""
HotkeyConfig["SC010"][MOD_RALT] := ""
HotkeyConfig["SC010"][MOD_RSHIFT] := ""
HotkeyConfig["SC010"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC010"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC010"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC010"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC013"] := [] ; "r"
HotkeyConfig["SC013"][MOD_RCTRL] := ""
HotkeyConfig["SC013"][MOD_RALT] := ""
HotkeyConfig["SC013"][MOD_RSHIFT] := ""
HotkeyConfig["SC013"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC013"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC013"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC013"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC01F"] := [] ; "s"
HotkeyConfig["SC01F"][MOD_RCTRL] := ""
HotkeyConfig["SC01F"][MOD_RALT] := ""
HotkeyConfig["SC01F"][MOD_RSHIFT] := ""
HotkeyConfig["SC01F"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC01F"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC01F"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC01F"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC014"] := [] ; "t"
HotkeyConfig["SC014"][MOD_RCTRL] := ""
HotkeyConfig["SC014"][MOD_RALT] := ""
HotkeyConfig["SC014"][MOD_RSHIFT] := ""
HotkeyConfig["SC014"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC014"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC014"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC014"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC016"] := [] ; "u"
HotkeyConfig["SC016"][MOD_RCTRL] := ""
HotkeyConfig["SC016"][MOD_RALT] := ""
HotkeyConfig["SC016"][MOD_RSHIFT] := ""
HotkeyConfig["SC016"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC016"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC016"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC016"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC02F"] := [] ; "v"
HotkeyConfig["SC02F"][MOD_RCTRL] := ""
HotkeyConfig["SC02F"][MOD_RALT] := ""
HotkeyConfig["SC02F"][MOD_RSHIFT] := ""
HotkeyConfig["SC02F"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC02F"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC02F"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC02F"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC011"] := [] ; "w"
HotkeyConfig["SC011"][MOD_RCTRL] := ""
HotkeyConfig["SC011"][MOD_RALT] := ""
HotkeyConfig["SC011"][MOD_RSHIFT] := ""
HotkeyConfig["SC011"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC011"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC011"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC011"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC02D"] := [] ; "x"
HotkeyConfig["SC02D"][MOD_RCTRL] := ""
HotkeyConfig["SC02D"][MOD_RALT] := ""
HotkeyConfig["SC02D"][MOD_RSHIFT] := ""
HotkeyConfig["SC02D"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC02D"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC02D"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC02D"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC015"] := [] ; "y"
HotkeyConfig["SC015"][MOD_RCTRL] := ""
HotkeyConfig["SC015"][MOD_RALT] := ""
HotkeyConfig["SC015"][MOD_RSHIFT] := ""
HotkeyConfig["SC015"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC015"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC015"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC015"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC02C"] := [] ; "z"
HotkeyConfig["SC02C"][MOD_RCTRL] := ""
HotkeyConfig["SC02C"][MOD_RALT] := ""
HotkeyConfig["SC02C"][MOD_RSHIFT] := ""
HotkeyConfig["SC02C"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC02C"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC02C"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC02C"][MOD_RCTRL_RALT_RSHIFT] := ""

; === FUNCTION KEYS ===
HotkeyConfig["SC03B"] := [] ; "F1"
HotkeyConfig["SC03B"][MOD_RCTRL] := ""
HotkeyConfig["SC03B"][MOD_RALT] := ""
HotkeyConfig["SC03B"][MOD_RSHIFT] := ""
HotkeyConfig["SC03B"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC03B"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC03B"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC03B"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC03C"] := [] ; "F2"
HotkeyConfig["SC03C"][MOD_RCTRL] := ""
HotkeyConfig["SC03C"][MOD_RALT] := ""
HotkeyConfig["SC03C"][MOD_RSHIFT] := ""
HotkeyConfig["SC03C"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC03C"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC03C"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC03C"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC03D"] := [] ; "F3"
HotkeyConfig["SC03D"][MOD_RCTRL] := ""
HotkeyConfig["SC03D"][MOD_RALT] := ""
HotkeyConfig["SC03D"][MOD_RSHIFT] := ""
HotkeyConfig["SC03D"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC03D"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC03D"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC03D"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC03E"] := [] ; "F4"
HotkeyConfig["SC03E"][MOD_RCTRL] := ""
HotkeyConfig["SC03E"][MOD_RALT] := ""
HotkeyConfig["SC03E"][MOD_RSHIFT] := ""
HotkeyConfig["SC03E"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC03E"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC03E"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC03E"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC03F"] := [] ; "F5"
HotkeyConfig["SC03F"][MOD_RCTRL] := ""
HotkeyConfig["SC03F"][MOD_RALT] := ""
HotkeyConfig["SC03F"][MOD_RSHIFT] := ""
HotkeyConfig["SC03F"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC03F"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC03F"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC03F"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC040"] := [] ; "F6"
HotkeyConfig["SC040"][MOD_RCTRL] := ""
HotkeyConfig["SC040"][MOD_RALT] := ""
HotkeyConfig["SC040"][MOD_RSHIFT] := ""
HotkeyConfig["SC040"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC040"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC040"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC040"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC041"] := [] ; "F7"
HotkeyConfig["SC041"][MOD_RCTRL] := ""
HotkeyConfig["SC041"][MOD_RALT] := ""
HotkeyConfig["SC041"][MOD_RSHIFT] := ""
HotkeyConfig["SC041"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC041"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC041"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC041"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC042"] := [] ; "F8"
HotkeyConfig["SC042"][MOD_RCTRL] := ""
HotkeyConfig["SC042"][MOD_RALT] := ""
HotkeyConfig["SC042"][MOD_RSHIFT] := ""
HotkeyConfig["SC042"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC042"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC042"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC042"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC043"] := [] ; "F9"
HotkeyConfig["SC043"][MOD_RCTRL] := ""
HotkeyConfig["SC043"][MOD_RALT] := ""
HotkeyConfig["SC043"][MOD_RSHIFT] := ""
HotkeyConfig["SC043"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC043"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC043"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC043"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC044"] := [] ; "F10"
HotkeyConfig["SC044"][MOD_RCTRL] := ""
HotkeyConfig["SC044"][MOD_RALT] := ""
HotkeyConfig["SC044"][MOD_RSHIFT] := ""
HotkeyConfig["SC044"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC044"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC044"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC044"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC057"] := [] ; "F11"
HotkeyConfig["SC057"][MOD_RCTRL] := ""
HotkeyConfig["SC057"][MOD_RALT] := ""
HotkeyConfig["SC057"][MOD_RSHIFT] := ""
HotkeyConfig["SC057"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC057"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC057"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC057"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC058"] := [] ; "F12"
HotkeyConfig["SC058"][MOD_RCTRL] := ""
HotkeyConfig["SC058"][MOD_RALT] := ""
HotkeyConfig["SC058"][MOD_RSHIFT] := ""
HotkeyConfig["SC058"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC058"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC058"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC058"][MOD_RCTRL_RALT_RSHIFT] := ""

; === SYMBOLS ===
HotkeyConfig["SC027"] := [] ; ";"
HotkeyConfig["SC027"][MOD_RCTRL] := ""
HotkeyConfig["SC027"][MOD_RALT] := ""
HotkeyConfig["SC027"][MOD_RSHIFT] := ""
HotkeyConfig["SC027"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC027"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC027"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC027"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC033"] := [] ; ","
HotkeyConfig["SC033"][MOD_RCTRL] := ""
HotkeyConfig["SC033"][MOD_RALT] := ""
HotkeyConfig["SC033"][MOD_RSHIFT] := ""
HotkeyConfig["SC033"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC033"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC033"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC033"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC034"] := [] ; "."
HotkeyConfig["SC034"][MOD_RCTRL] := ""
HotkeyConfig["SC034"][MOD_RALT] := ""
HotkeyConfig["SC034"][MOD_RSHIFT] := ""
HotkeyConfig["SC034"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC034"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC034"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC034"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC035"] := [] ; "/"
HotkeyConfig["SC035"][MOD_RCTRL] := ""
HotkeyConfig["SC035"][MOD_RALT] := ""
HotkeyConfig["SC035"][MOD_RSHIFT] := ""
HotkeyConfig["SC035"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC035"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC035"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC035"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC01A"] := [] ; "["
HotkeyConfig["SC01A"][MOD_RCTRL] := ""
HotkeyConfig["SC01A"][MOD_RALT] := ""
HotkeyConfig["SC01A"][MOD_RSHIFT] := ""
HotkeyConfig["SC01A"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC01A"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC01A"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC01A"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC01B"] := [] ; "]"
HotkeyConfig["SC01B"][MOD_RCTRL] := ""
HotkeyConfig["SC01B"][MOD_RALT] := ""
HotkeyConfig["SC01B"][MOD_RSHIFT] := ""
HotkeyConfig["SC01B"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC01B"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC01B"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC01B"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC02B"] := [] ; "\"
HotkeyConfig["SC02B"][MOD_RCTRL] := ""
HotkeyConfig["SC02B"][MOD_RALT] := ""
HotkeyConfig["SC02B"][MOD_RSHIFT] := ""
HotkeyConfig["SC02B"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC02B"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC02B"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC02B"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC028"] := [] ; "'"
HotkeyConfig["SC028"][MOD_RCTRL] := ""
HotkeyConfig["SC028"][MOD_RALT] := ""
HotkeyConfig["SC028"][MOD_RSHIFT] := "^x"
HotkeyConfig["SC028"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC028"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC028"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC028"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC00C"] := [] ; "-"
HotkeyConfig["SC00C"][MOD_RCTRL] := ""
HotkeyConfig["SC00C"][MOD_RALT] := ""
HotkeyConfig["SC00C"][MOD_RSHIFT] := ""
HotkeyConfig["SC00C"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC00C"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC00C"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC00C"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC00D"] := [] ; "="
HotkeyConfig["SC00D"][MOD_RCTRL] := ""
HotkeyConfig["SC00D"][MOD_RALT] := ""
HotkeyConfig["SC00D"][MOD_RSHIFT] := ""
HotkeyConfig["SC00D"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC00D"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC00D"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC00D"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC029"] := [] ; "`"
HotkeyConfig["SC029"][MOD_RCTRL] := ""
HotkeyConfig["SC029"][MOD_RALT] := ""
HotkeyConfig["SC029"][MOD_RSHIFT] := ""
HotkeyConfig["SC029"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC029"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC029"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC029"][MOD_RCTRL_RALT_RSHIFT] := ""

; === NAVIGATION KEYS ===
HotkeyConfig["SC148"] := [] ; "Up"
HotkeyConfig["SC148"][MOD_RCTRL] := ""
HotkeyConfig["SC148"][MOD_RALT] := ""
HotkeyConfig["SC148"][MOD_RSHIFT] := ""
HotkeyConfig["SC148"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC148"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC148"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC148"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC150"] := [] ; "Down"
HotkeyConfig["SC150"][MOD_RCTRL] := ""
HotkeyConfig["SC150"][MOD_RALT] := ""
HotkeyConfig["SC150"][MOD_RSHIFT] := ""
HotkeyConfig["SC150"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC150"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC150"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC150"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC14B"] := [] ; "Left"
HotkeyConfig["SC14B"][MOD_RCTRL] := ""
HotkeyConfig["SC14B"][MOD_RALT] := ""
HotkeyConfig["SC14B"][MOD_RSHIFT] := ""
HotkeyConfig["SC14B"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC14B"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC14B"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC14B"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC14D"] := [] ; "Right"
HotkeyConfig["SC14D"][MOD_RCTRL] := ""
HotkeyConfig["SC14D"][MOD_RALT] := ""
HotkeyConfig["SC14D"][MOD_RSHIFT] := ""
HotkeyConfig["SC14D"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC14D"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC14D"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC14D"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC147"] := [] ; "Home"
HotkeyConfig["SC147"][MOD_RCTRL] := ""
HotkeyConfig["SC147"][MOD_RALT] := ""
HotkeyConfig["SC147"][MOD_RSHIFT] := ""
HotkeyConfig["SC147"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC147"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC147"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC147"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC14F"] := [] ; "End"
HotkeyConfig["SC14F"][MOD_RCTRL] := ""
HotkeyConfig["SC14F"][MOD_RALT] := ""
HotkeyConfig["SC14F"][MOD_RSHIFT] := ""
HotkeyConfig["SC14F"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC14F"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC14F"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC14F"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC149"] := [] ; "PgUp"
HotkeyConfig["SC149"][MOD_RCTRL] := ""
HotkeyConfig["SC149"][MOD_RALT] := ""
HotkeyConfig["SC149"][MOD_RSHIFT] := ""
HotkeyConfig["SC149"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC149"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC149"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC149"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC151"] := [] ; "PgDn"
HotkeyConfig["SC151"][MOD_RCTRL] := ""
HotkeyConfig["SC151"][MOD_RALT] := ""
HotkeyConfig["SC151"][MOD_RSHIFT] := ""
HotkeyConfig["SC151"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC151"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC151"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC151"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC152"] := [] ; "Insert"
HotkeyConfig["SC152"][MOD_RCTRL] := ""
HotkeyConfig["SC152"][MOD_RALT] := ""
HotkeyConfig["SC152"][MOD_RSHIFT] := ""
HotkeyConfig["SC152"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC152"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC152"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC152"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC153"] := [] ; "Delete"
HotkeyConfig["SC153"][MOD_RCTRL] := ""
HotkeyConfig["SC153"][MOD_RALT] := ""
HotkeyConfig["SC153"][MOD_RSHIFT] := ""
HotkeyConfig["SC153"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC153"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC153"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC153"][MOD_RCTRL_RALT_RSHIFT] := ""

; === NUMPAD KEYS ===
HotkeyConfig["SC052"] := [] ; "Numpad0"
HotkeyConfig["SC052"][MOD_RCTRL] := ""
HotkeyConfig["SC052"][MOD_RALT] := ""
HotkeyConfig["SC052"][MOD_RSHIFT] := ""
HotkeyConfig["SC052"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC052"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC052"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC052"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04F"] := [] ; "Numpad1"
HotkeyConfig["SC04F"][MOD_RCTRL] := ""
HotkeyConfig["SC04F"][MOD_RALT] := ""
HotkeyConfig["SC04F"][MOD_RSHIFT] := ""
HotkeyConfig["SC04F"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04F"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04F"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04F"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC050"] := [] ; "Numpad2"
HotkeyConfig["SC050"][MOD_RCTRL] := ""
HotkeyConfig["SC050"][MOD_RALT] := ""
HotkeyConfig["SC050"][MOD_RSHIFT] := ""
HotkeyConfig["SC050"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC050"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC050"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC050"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC051"] := [] ; "Numpad3"
HotkeyConfig["SC051"][MOD_RCTRL] := ""
HotkeyConfig["SC051"][MOD_RALT] := ""
HotkeyConfig["SC051"][MOD_RSHIFT] := ""
HotkeyConfig["SC051"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC051"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC051"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC051"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04B"] := [] ; "Numpad4"
HotkeyConfig["SC04B"][MOD_RCTRL] := ""
HotkeyConfig["SC04B"][MOD_RALT] := ""
HotkeyConfig["SC04B"][MOD_RSHIFT] := ""
HotkeyConfig["SC04B"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04B"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04B"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04B"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04C"] := [] ; "Numpad5"
HotkeyConfig["SC04C"][MOD_RCTRL] := ""
HotkeyConfig["SC04C"][MOD_RALT] := ""
HotkeyConfig["SC04C"][MOD_RSHIFT] := ""
HotkeyConfig["SC04C"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04C"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04C"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04C"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04D"] := [] ; "Numpad6"
HotkeyConfig["SC04D"][MOD_RCTRL] := ""
HotkeyConfig["SC04D"][MOD_RALT] := ""
HotkeyConfig["SC04D"][MOD_RSHIFT] := ""
HotkeyConfig["SC04D"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04D"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04D"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04D"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC047"] := [] ; "Numpad7"
HotkeyConfig["SC047"][MOD_RCTRL] := ""
HotkeyConfig["SC047"][MOD_RALT] := ""
HotkeyConfig["SC047"][MOD_RSHIFT] := ""
HotkeyConfig["SC047"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC047"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC047"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC047"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC048"] := [] ; "Numpad8"
HotkeyConfig["SC048"][MOD_RCTRL] := ""
HotkeyConfig["SC048"][MOD_RALT] := ""
HotkeyConfig["SC048"][MOD_RSHIFT] := ""
HotkeyConfig["SC048"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC048"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC048"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC048"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC049"] := [] ; "Numpad9"
HotkeyConfig["SC049"][MOD_RCTRL] := ""
HotkeyConfig["SC049"][MOD_RALT] := ""
HotkeyConfig["SC049"][MOD_RSHIFT] := ""
HotkeyConfig["SC049"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC049"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC049"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC049"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC053"] := [] ; "NumpadDot"
HotkeyConfig["SC053"][MOD_RCTRL] := ""
HotkeyConfig["SC053"][MOD_RALT] := ""
HotkeyConfig["SC053"][MOD_RSHIFT] := ""
HotkeyConfig["SC053"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC053"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC053"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC053"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["NumpadEnter"] := [] ; "NumpadEnter"
HotkeyConfig["NumpadEnter"][MOD_RCTRL] := ""
HotkeyConfig["NumpadEnter"][MOD_RALT] := ""
HotkeyConfig["NumpadEnter"][MOD_RSHIFT] := ""
HotkeyConfig["NumpadEnter"][MOD_RCTRL_RALT] := ""
HotkeyConfig["NumpadEnter"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["NumpadEnter"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["NumpadEnter"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04E"] := [] ; "NumpadAdd"
HotkeyConfig["SC04E"][MOD_RCTRL] := ""
HotkeyConfig["SC04E"][MOD_RALT] := ""
HotkeyConfig["SC04E"][MOD_RSHIFT] := ""
HotkeyConfig["SC04E"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04E"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04E"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04E"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC04A"] := [] ; "NumpadSub"
HotkeyConfig["SC04A"][MOD_RCTRL] := ""
HotkeyConfig["SC04A"][MOD_RALT] := ""
HotkeyConfig["SC04A"][MOD_RSHIFT] := ""
HotkeyConfig["SC04A"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC04A"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC04A"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC04A"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["SC037"] := [] ; "NumpadMult"
HotkeyConfig["SC037"][MOD_RCTRL] := ""
HotkeyConfig["SC037"][MOD_RALT] := ""
HotkeyConfig["SC037"][MOD_RSHIFT] := ""
HotkeyConfig["SC037"][MOD_RCTRL_RALT] := ""
HotkeyConfig["SC037"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["SC037"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["SC037"][MOD_RCTRL_RALT_RSHIFT] := ""

HotkeyConfig["NumpadDiv"] := [] ; "NumpadDiv"
HotkeyConfig["NumpadDiv"][MOD_RCTRL] := ""
HotkeyConfig["NumpadDiv"][MOD_RALT] := ""
HotkeyConfig["NumpadDiv"][MOD_RSHIFT] := ""
HotkeyConfig["NumpadDiv"][MOD_RCTRL_RALT] := ""
HotkeyConfig["NumpadDiv"][MOD_RCTRL_RSHIFT] := ""
HotkeyConfig["NumpadDiv"][MOD_RALT_RSHIFT] := ""
HotkeyConfig["NumpadDiv"][MOD_RCTRL_RALT_RSHIFT] := ""

; =============================================
; MODIFIER TRACKING
; =============================================

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

; =============================================
; HOTKEY HANDLER FUNCTION
; =============================================

HandleHotkey(key) {
    global rctrlPressed, raltPressed, rshiftPressed, HotkeyConfig
    global MOD_RCTRL, MOD_RALT, MOD_RSHIFT, MOD_RCTRL_RALT, MOD_RCTRL_RSHIFT, MOD_RALT_RSHIFT, MOD_RCTRL_RALT_RSHIFT
    
    config := HotkeyConfig[key]
    if (!IsObject(config)) {
        return
    }
    
    ; Determine modifier combination
    modifierIndex := 0
    if (rctrlPressed && raltPressed && rshiftPressed) {
        modifierIndex := MOD_RCTRL_RALT_RSHIFT
    } else if (rctrlPressed && raltPressed) {
        modifierIndex := MOD_RCTRL_RALT
    } else if (rctrlPressed && rshiftPressed) {
        modifierIndex := MOD_RCTRL_RSHIFT
    } else if (raltPressed && rshiftPressed) {
        modifierIndex := MOD_RALT_RSHIFT
    } else if (rctrlPressed) {
        modifierIndex := MOD_RCTRL
    } else if (raltPressed) {
        modifierIndex := MOD_RALT
    } else if (rshiftPressed) {
        modifierIndex := MOD_RSHIFT
    }
    
    ; Execute action if defined for this modifier combination
    if (modifierIndex > 0 && config.HasKey(modifierIndex) && config[modifierIndex] != "") {
        action := config[modifierIndex]
        if (IsFunc(action)) {
            %action%()
        } else {
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

; =============================================
; HOTKEY DEFINITIONS
; =============================================

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