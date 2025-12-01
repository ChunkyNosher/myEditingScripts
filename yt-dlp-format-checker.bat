@echo off
setlocal EnableDelayedExpansion

set "LIST_FILE=yt_download_list.txt"
set "BROWSER_FILE=browser_choice.txt"
set "TEMP_FULL_FORMAT=temp_full_format.txt"

:MAIN_MENU
cls
echo ==============================
echo Format Checker - Separate Tool
echo ==============================
echo.
if exist "%LIST_FILE%" (
    for /f %%C in ('find /c /v "" ^< "%LIST_FILE%"') do set "COUNT=%%C"
) else (
    set "COUNT=0"
)
echo Current list has !COUNT! links
echo.
echo 1. Check Available Formats (All Videos - With Prediction)
echo 2. Check Available Formats (Single Video)
echo.
echo 3. Back to Main Program
echo.
choice /c 123 /n /m "Choose an option: "
set CHOICE=%errorlevel%

if %CHOICE%==1 goto CHECK_FORMATS_ALL_WITH_PREDICTION
if %CHOICE%==2 goto CHECK_FORMATS_SINGLE
if %CHOICE%==3 goto END
goto MAIN_MENU

:CHECK_FORMATS_ALL_WITH_PREDICTION
cls
if not exist "%BROWSER_FILE%" (
    echo Browser for Premium access not set!
    echo Please set your browser first in the main program.
    pause
    goto MAIN_MENU
)
if not exist "%LIST_FILE%" (
    echo No videos in list!
    pause
    goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo ==============================
echo Checking Formats for All Videos
echo With Codec Detection
echo ==============================
echo.
echo Extracting cookies from !BROWSER_CHOICE!...
echo Browser must be CLOSED for cookies to work.
echo.
pause
set VIDEO_COUNT=0
for /f "usebackq delims=" %%U in ("%LIST_FILE%") do (
    set /a VIDEO_COUNT+=1
    cls
    echo.
    echo ==============================
    echo VIDEO #!VIDEO_COUNT! of !COUNT!
    echo ==============================
    echo.
    echo URL: %%U
    echo.
    echo === AVAILABLE FORMATS ===
    yt-dlp --list-formats "%%U" --cookies-from-browser !BROWSER_CHOICE! 2>&1 > "!TEMP_FULL_FORMAT!"
    type "!TEMP_FULL_FORMAT!"
    echo.
    echo === CODEC DETECTION ===
    echo.
    set "FINAL_CODEC=UNKNOWN"
    
    findstr /i "premium" "!TEMP_FULL_FORMAT!" > nul
    if !errorlevel! equ 0 (
        set "FINAL_CODEC=PREMIUM"
    ) else (
        findstr /i "av01 av1" "!TEMP_FULL_FORMAT!" | findstr /v "243 278 394 242 395 396 244 397" > nul
        if !errorlevel! equ 0 (
            set "FINAL_CODEC=AV1"
        ) else (
            findstr /i "vp09 vp9 vp0" "!TEMP_FULL_FORMAT!" | findstr /v "243 278 394 242 395 396 244 397" > nul
            if !errorlevel! equ 0 (
                set "FINAL_CODEC=VP9"
            ) else (
                findstr /i "avc1 h264 avc" "!TEMP_FULL_FORMAT!" | findstr /v "243 278 394 242 395 396 244 397" > nul
                if !errorlevel! equ 0 (
                    set "FINAL_CODEC=H264"
                )
            )
        )
    )
    
    echo [CODEC DETECTION RESULT]
    echo.
    echo Detected Codec: !FINAL_CODEC!
    echo.
    
    if "!FINAL_CODEC!"=="PREMIUM" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: HIGHEST AVAILABLE
    ) else if "!FINAL_CODEC!"=="AV1" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: EXCELLENT - AV1 Codec Detected
    ) else if "!FINAL_CODEC!"=="VP9" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: EXCELLENT - VP9 Codec Detected
    ) else if "!FINAL_CODEC!"=="H264" (
        echo Action in Main Program: Download WITHOUT Re-encoding
        echo Quality: GOOD - Standard H.264 Codec
    ) else (
        echo Action in Main Program: Standard Download
        echo Quality: VARIABLE
    )
    
    if exist "!TEMP_FULL_FORMAT!" del "!TEMP_FULL_FORMAT!"
    echo.
    echo ==============================
    echo Press any key to continue to next video...
    echo ==============================
    pause >nul
)
echo.
cls
echo ==============================
echo Format check complete for all !COUNT! videos
echo ==============================
echo.
pause
goto MAIN_MENU

:END
endlocal
exit /b