# GitHub Copilot Instructions for myEditingScripts

## Repository Overview

This repository contains productivity and video editing automation scripts for Windows:
- **AutoHotkey v1.1** scripts for hotkeys, window management, and system automation
- **Windows Batch files** for yt-dlp video downloading with encoding profiles
- **Adobe Premiere Pro** integration scripts

**CRITICAL**: This repository uses AutoHotkey v1.1, NOT v2. All syntax must be v1-compatible.

---

## AutoHotkey v1.1 Syntax Rules (MANDATORY)

### ⚠️ Language Version Enforcement

**This project uses AutoHotkey v1.1.37+, NOT AutoHotkey v2.**

All code suggestions MUST use v1 syntax. v2 syntax will break existing scripts.

### Command Syntax (NOT Function Syntax)

#### ✅ CORRECT v1 Syntax
```ahk
MsgBox, Hello World
Send, {Enter}
Run, notepad.exe
WinActivate, ahk_exe chrome.exe
IfWinExist, ahk_class Notepad
StringLen, length, myVariable
Sleep, 1000
```

#### ❌ INCORRECT v2 Syntax - NEVER USE
```ahk
MsgBox("Hello World")           ; NO - This is v2
Send("{Enter}")                  ; NO - This is v2
Run("notepad.exe")               ; NO - This is v2
WinActivate("ahk_exe chrome.exe") ; NO - This is v2
if WinExist("ahk_class Notepad") ; NO - This is v2
length := StrLen(myVariable)     ; NO - This is v2
Sleep(1000)                      ; NO - This is v2
```

### Variable Assignment

#### ✅ CORRECT v1
```ahk
; Assignment operator
myVar := "value"
counter := 5

; Legacy assignment (still valid in v1)
myVar = value

; Retrieve variable
MsgBox, %myVar%
```

#### ❌ INCORRECT - v2 style
```ahk
myVar := "value"
MsgBox(myVar)  ; NO - missing % in v1 when using MsgBox command
```

### Conditional Statements

#### ✅ CORRECT v1
```ahk
If (condition)
{
    ; code
}

IfWinExist, ahk_exe notepad.exe
{
    WinActivate
}

If ErrorLevel
{
    MsgBox, Error occurred
}
```

#### ❌ INCORRECT v2
```ahk
if condition {  ; NO - lowercase 'if' with brace on same line
    ; code
}

if WinExist("notepad.exe") {  ; NO - This is v2
    WinActivate()
}
```

### Hotkey Definitions

#### ✅ CORRECT v1
```ahk
; Single-line hotkey
^j::Send, Hello

; Multi-line hotkey with return
^k::
    Send, Line 1
    Sleep, 100
    Send, Line 2
return

; Hotkey with context
#IfWinActive ahk_exe Premiere Pro.exe
^p::MsgBox, Premiere is active
#IfWinActive
```

#### ❌ INCORRECT v2
```ahk
^j:: {           ; NO - v2 brace syntax
    Send("Hello")
}

; NO - v2 context syntax
#HotIf WinActive("ahk_exe Premiere Pro.exe")
^p:: MsgBox("Premiere is active")
```

### String Functions

#### ✅ CORRECT v1
```ahk
StringLen, length, myString
StringReplace, newString, oldString, find, replace
StringSplit, array, inputString, `,
StrReplace() ; v1 function (exists in v1 too)
```

#### ❌ INCORRECT v2 Only
```ahk
length := StrLen(myString)  ; NO - command form required in v1
```

### Loop Constructs

#### ✅ CORRECT v1
```ahk
Loop, 5
{
    MsgBox, Iteration %A_Index%
}

Loop, Parse, myString, `,
{
    MsgBox, Item: %A_LoopField%
}

Loop
{
    if (A_Index > 10)
        break
}
```

---

## Repository-Specific Patterns

### RightModifierHotkeys System

This is the main hotkey framework in the repository.

#### Key Architecture Concepts

1. **Custom Modifier Tracking** (v3.1 uses this approach)
```ahk
; Global state variables
global rctrlPressed := false
global raltPressed := false
global rshiftPressed := false

; Modifier constants for array indexing
global MOD_RCTRL := 1
global MOD_RALT := 2
global MOD_RSHIFT := 3
global MOD_RCTRL_RALT := 4
global MOD_RCTRL_RSHIFT := 5
global MOD_RALT_RSHIFT := 6
global MOD_RCTRL_RALT_RSHIFT := 7
```

2. **Array-Based Configuration** (v3.1 pattern)
```ahk
HotkeyConfig["SC030"] := [] ; "b" key
HotkeyConfig["SC030"][MOD_RCTRL] := "LaunchArc"
HotkeyConfig["SC030"][MOD_RALT] := ""
HotkeyConfig["SC030"][MOD_RSHIFT] := ""
```

3. **Object-Based Configuration** (v3 pattern)
```ahk
HotkeyConfig["SC030"] := {
    "RCtrl": "LaunchZen",
    "RAlt": "",
    "RShift": ""
}
```

#### Why We DON'T Use GetKeyState in Loops

**NEVER do this:**
```ahk
; BAD - Causes lag and missed keypresses
Loop
{
    if GetKeyState("RCtrl", "P")
        rctrlPressed := true
    Sleep, 10
}
```

**ALWAYS do this:**
```ahk
; GOOD - Event-driven with KeyWait
$RCtrl::
    rctrlPressed := true
    KeyWait, RCtrl, T2.0
    if (ErrorLevel = 0) {
        rctrlPressed := false
    } else {
        KeyWait, RCtrl
        rctrlPressed := false
    }
return
```

#### Modifier Handler Pattern

```ahk
HandleHotkey(key) {
    global rctrlPressed, raltPressed, rshiftPressed, HotkeyConfig
    
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
    } ; ... etc
    
    ; Execute action
    if (modifierIndex > 0 && config[modifierIndex] != "") {
        action := config[modifierIndex]
        if (IsFunc(action)) {
            %action%()
        } else {
            SendInput, %action%
        }
    }
}
```

### File Includes Pattern

Scripts include other scripts for modularity:

```ahk
#Include Open Folders v2.ahk
#Include Premiere Preset Hotkeys.ahk
```

**Important**: When modifying included files, ensure:
- Path is relative to the main script
- File exists in repository
- No circular dependencies

### Application Launch/Activate Functions

Standard pattern for application launchers:

```ahk
LaunchAppName() {
    IfWinNotExist, ahk_exe AppName.exe
        Run, AppName.exe
    WinActivate, ahk_exe AppName.exe
}
```

For batch scripts with PID tracking:

```ahk
LaunchBatchScript() {
    static batchPID := 0
    
    ; Check if process exists
    if (batchPID != 0) {
        Process, Exist, %batchPID%
        if (ErrorLevel = batchPID) {
            WinActivate, ahk_pid %batchPID%
            return
        } else {
            batchPID := 0
        }
    }
    
    ; Launch new process
    Run, "E:\path\to\script.bat", , , batchPID
    Sleep, 1000
}
```

### Admin Rights Requirement

Many scripts require admin privileges:

```ahk
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}
```

**Why**: Prevents keyboard input blocking when Task Manager or other admin windows are active.

---

## Windows Batch File Guidelines

### Standard Structure

```batch
@echo off
setlocal EnableDelayedExpansion

rem ==============================
rem Script Name
rem ==============================

set "VAR_NAME=value"

:MAIN_MENU
rem Main logic here

:END
endlocal
exit /b
```

### Critical Patterns

#### Delayed Expansion

**Always use** `EnableDelayedExpansion` and `!variable!` syntax in loops:

```batch
setlocal EnableDelayedExpansion

for /f %%i in (file.txt) do (
    set LINE=%%i
    echo !LINE!          rem CORRECT - uses !
    echo %LINE%          rem WRONG - will be empty
)
```

#### Error Handling

```batch
command
if !errorlevel! equ 0 (
    echo Success
) else (
    echo Failed with code: !errorlevel!
    exit /b !errorlevel!
)
```

#### Variable Safety

```batch
rem Always quote variables in conditionals
if not "!VAR!"=="" (
    echo Variable is set
)

rem Protect against spaces
if exist "!DOWNLOAD_DIR!" (
    cd /d "!DOWNLOAD_DIR!"
)
```

### yt-dlp Scripts Specific

#### Browser Cookie Pattern

```batch
set "BROWSER_FILE=browser_choice.txt"

rem Always check file exists
if not exist "%BROWSER_FILE%" (
    echo Browser not set!
    pause
    goto MAIN_MENU
)

rem Load browser choice
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"

rem Use in yt-dlp command
yt-dlp --cookies-from-browser !BROWSER_CHOICE! "URL"
```

#### Codec Detection Pattern

```batch
set "TEMP_FORMAT_FILE=temp_format_check.txt"

rem Get format info
yt-dlp --list-formats "!VIDEO_URL!" --cookies-from-browser !BROWSER_CHOICE! 2>nul > "!TEMP_FORMAT_FILE!"

rem Detect premium
findstr /i "premium" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
    set "CODEC_TYPE=PREMIUM"
) else (
    rem Detect AV1 (exclude low quality formats)
    findstr /i "av01" "!TEMP_FORMAT_FILE!" | findstr /v "243 278 394 242 395 396 244 397" >nul 2>&1
    if !errorlevel! equ 0 (
        set "CODEC_TYPE=AV1"
    )
)

rem Clean up temp file
if exist "!TEMP_FORMAT_FILE!" del "!TEMP_FORMAT_FILE!"
```

#### ffmpeg Integration

```batch
rem Define encoding args based on profile
if %GPU_CHOICE%==1 (
    set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -cq 18 -b:v 0 -rc vbr -multipass 2 -spatial-aq 1 -temporal-aq 1 -c:a aac -b:a 128k"
    set "PROFILE=STANDARD"
)

rem Use with yt-dlp
yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 ^
    --cookies-from-browser !BROWSER_CHOICE! ^
    --postprocessor-args "!FFMPEG_ARGS!" ^
    -o "!DOWNLOAD_DIR!\%%(title)s_!MODE!.%%(ext)s" ^
    "!VIDEO_URL!"
```

---

## Debugging Practices

### AutoHotkey Debugging

#### ToolTip for Runtime Debug
```ahk
ToolTip, Variable value: %myVar%`nAnother: %otherVar%
Sleep, 2000
ToolTip  ; Clear
```

#### OutputDebug for External Monitoring
```ahk
OutputDebug, Reached checkpoint 1
OutputDebug, Counter value: %counter%
```

Use with DebugView or VS Code debugger.

#### ListVars for State Inspection
```ahk
ListVars  ; Opens window showing all variables
Pause     ; Allows inspection before continuing
```

### Batch File Debugging

#### Echo Commands
```batch
rem Remove @echo off temporarily to see all commands
rem @echo off

echo Starting process...
echo Variable: !VAR!
pause
```

#### Error Redirection
```batch
rem Capture errors to file
command 2>error.log

rem Capture both output and errors
command >output.log 2>&1
```

#### Variable Dump
```batch
rem Show all environment variables
set

rem Show specific variable
set VAR

pause
```

---

## Common Mistakes to Avoid

### 1. Using v2 Syntax in v1 Scripts

❌ **WRONG:**
```ahk
MsgBox("Hello")
if WinExist("Notepad") {
    WinActivate()
}
```

✅ **CORRECT:**
```ahk
MsgBox, Hello
IfWinExist, Notepad
{
    WinActivate
}
```

### 2. Missing Return Statement

❌ **WRONG:**
```ahk
^j::
    Send, Hello
^k::
    Send, World
return
```

✅ **CORRECT:**
```ahk
^j::
    Send, Hello
return

^k::
    Send, World
return
```

### 3. Forgetting Delayed Expansion in Batch

❌ **WRONG:**
```batch
for /f %%i in (file.txt) do (
    set VAR=%%i
    echo %VAR%    rem Will be empty!
)
```

✅ **CORRECT:**
```batch
setlocal EnableDelayedExpansion
for /f %%i in (file.txt) do (
    set VAR=%%i
    echo !VAR!
)
```

### 4. Not Quoting Paths with Spaces

❌ **WRONG:**
```batch
cd !DOWNLOAD_DIR!
if exist !FILE! echo Found
```

✅ **CORRECT:**
```batch
cd /d "!DOWNLOAD_DIR!"
if exist "!FILE!" echo Found
```

---

## Documentation References

### AutoHotkey v1
- **Main Documentation**: https://www.autohotkey.com/docs/v1/
- **Commands Reference**: https://www.autohotkey.com/docs/v1/lib/
- **Concepts & Conventions**: https://www.autohotkey.com/docs/v1/Concepts.htm
- **Tutorial**: https://www.autohotkey.com/docs/v1/Tutorial.htm
- **Debugging**: https://www.autohotkey.com/docs/v1/AHKL_DBGPClients.htm

### Batch Scripting
- **Windows Batch Scripting Guide**: https://en.wikibooks.org/wiki/Windows_Batch_Scripting
- **Windows Commands Reference**: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/
- **Debugging Best Practices**: https://stackoverflow.com/questions/165938/how-can-i-debug-a-bat-script

### Tools
- **yt-dlp**: https://github.com/yt-dlp/yt-dlp
- **ffmpeg**: https://ffmpeg.org/documentation.html

---

## Code Review Checklist

Before suggesting any code changes, verify:

- [ ] **AutoHotkey version**: Is this v1 syntax, not v2?
- [ ] **Commands use commas**: `MsgBox, text` not `MsgBox("text")`
- [ ] **Return statements**: Every multi-line hotkey has `return`
- [ ] **Admin check**: Scripts that need admin rights have the check
- [ ] **Delayed expansion**: Batch loops use `!variable!` not `%variable%`
- [ ] **Error handling**: Batch commands check `!errorlevel!`
- [ ] **Path quoting**: All file paths in batch are quoted
- [ ] **Variable safety**: Conditionals check for empty/undefined variables

---

## When in Doubt

1. **Check existing code patterns** in the repository first
2. **Prefer v1 command syntax** over expression syntax when both work
3. **Test with ToolTip/echo** before committing to complex logic
4. **Reference official v1 docs**, not v2 docs
5. **Ask for clarification** if v1/v2 syntax is unclear

---

**Last Updated**: December 1, 2025  
**AutoHotkey Version**: v1.1.37+  
**Batch Script Version**: Windows 10/11 cmd.exe
