@echo off
setlocal EnableDelayedExpansion

rem ==============================
rem Dependencies folder setup
rem ==============================
set "DEPS_FOLDER=yt-dlp batch downloader dependencies"

rem Use dependencies folder for files
set "LIST_FILE=%DEPS_FOLDER%\yt_download_list.txt"
set "BROWSER_FILE=%DEPS_FOLDER%\browser_choice.txt"
set "TEMP_FULL_FORMAT=%DEPS_FOLDER%\temp_full_format.txt"

rem Fallback to old location if dependencies folder doesn't exist
if not exist "%DEPS_FOLDER%" (
    set "LIST_FILE=yt_download_list.txt"
    set "BROWSER_FILE=browser_choice.txt"
    set "TEMP_FULL_FORMAT=temp_full_format.txt"
)

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
    yt-dlp --list-formats "%%U" --cookies-from-browser !BROWSER_CHOICE! -v 2>"!TEMP_FULL_FORMAT!.debug" > "!TEMP_FULL_FORMAT!"
    type "!TEMP_FULL_FORMAT!"
    echo.
    echo === CODEC DETECTION ===
    echo.
    set "FINAL_CODEC=UNKNOWN"
    set "PREMIUM_DETECTED=0"
    
    rem Check for YouTube Premium subscription in verbose output
    findstr /i /c:"Detected YouTube Premium" "!TEMP_FULL_FORMAT!.debug" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [INFO] YouTube Premium subscription detected
    )
    
    rem Check for specific premium format IDs at line beginning only
    rem Per youtube-format-ids.md: Format 356, 616, 721, 774 are premium-exclusive
    for %%F in (356 616 721 774) do (
        findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
        if !errorlevel! equ 0 (
            set "PREMIUM_DETECTED=1"
            echo [INFO] Premium Format ID %%F detected
        )
    )
    
    if "!PREMIUM_DETECTED!"=="1" (
        set "FINAL_CODEC=PREMIUM"
    ) else (
        rem Check for AV1 1080p format IDs (399=30fps, 699=60fps HFR)
        set "AV1_FOUND=0"
        for %%F in (399 699) do (
            findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
            if !errorlevel! equ 0 (
                set "AV1_FOUND=1"
                echo [INFO] AV1 1080p Format ID %%F detected
            )
        )
        if "!AV1_FOUND!"=="1" (
            set "FINAL_CODEC=AV1"
        ) else (
            rem Check for VP9 format IDs (248, 303, 247, 302)
            set "VP9_FOUND=0"
            for %%F in (248 303 247 302) do (
                findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
                if !errorlevel! equ 0 (
                    set "VP9_FOUND=1"
                    echo [INFO] VP9 Format ID %%F detected
                )
            )
            rem Also check for vp09 codec string as fallback
            if "!VP9_FOUND!"=="0" (
                findstr /i "vp09 vp9" "!TEMP_FULL_FORMAT!" | findstr /v "243 278 242" >nul 2>&1
                if !errorlevel! equ 0 (
                    set "VP9_FOUND=1"
                    echo [INFO] VP9 codec detected via codec string
                )
            )
            if "!VP9_FOUND!"=="1" (
                set "FINAL_CODEC=VP9"
            ) else (
                rem Check for H.264 codec (avc1)
                findstr /i "avc1" "!TEMP_FULL_FORMAT!" >nul 2>&1
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
        echo Quality: HIGHEST AVAILABLE - Premium Format Detected
    ) else if "!FINAL_CODEC!"=="AV1" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: EXCELLENT - AV1 1080p Codec Detected
    ) else if "!FINAL_CODEC!"=="VP9" (
        echo Action in Main Program: Download WITHOUT Re-encoding
        echo Quality: EXCELLENT - VP9 Codec ^(skip re-encode policy^)
    ) else if "!FINAL_CODEC!"=="H264" (
        echo Action in Main Program: Download WITHOUT Re-encoding
        echo Quality: GOOD - Standard H.264 Codec
    ) else (
        echo Action in Main Program: Standard Download
        echo Quality: VARIABLE
    )
    
    if exist "!TEMP_FULL_FORMAT!" del "!TEMP_FULL_FORMAT!"
    if exist "!TEMP_FULL_FORMAT!.debug" del "!TEMP_FULL_FORMAT!.debug"
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

:CHECK_FORMATS_SINGLE
cls
if not exist "%BROWSER_FILE%" (
    echo Browser for Premium access not set!
    echo Please set your browser first in the main program.
    pause
    goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo ==============================
echo Check Single Video Format
echo ==============================
echo.
set /p "SINGLE_URL=Enter video URL: "
if "!SINGLE_URL!"=="" (
    echo No URL entered!
    pause
    goto MAIN_MENU
)
echo.
echo Extracting cookies from !BROWSER_CHOICE!...
echo Browser must be CLOSED for cookies to work.
echo.
echo === AVAILABLE FORMATS ===
yt-dlp --list-formats "!SINGLE_URL!" --cookies-from-browser !BROWSER_CHOICE! -v 2>"!TEMP_FULL_FORMAT!.debug" > "!TEMP_FULL_FORMAT!"
type "!TEMP_FULL_FORMAT!"
echo.
echo === CODEC DETECTION ===
echo.
set "FINAL_CODEC=UNKNOWN"
set "PREMIUM_DETECTED=0"

rem Check for YouTube Premium subscription in verbose output
findstr /i /c:"Detected YouTube Premium" "!TEMP_FULL_FORMAT!.debug" >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO] YouTube Premium subscription detected
)

rem Check for specific premium format IDs at line beginning only
rem Per youtube-format-ids.md: Format 356, 616, 721, 774 are premium-exclusive
for %%F in (356 616 721 774) do (
    findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
    if !errorlevel! equ 0 (
        set "PREMIUM_DETECTED=1"
        echo [INFO] Premium Format ID %%F detected
    )
)

if "!PREMIUM_DETECTED!"=="1" (
    set "FINAL_CODEC=PREMIUM"
) else (
    rem Check for AV1 1080p format IDs (399=30fps, 699=60fps HFR)
    set "AV1_FOUND=0"
    for %%F in (399 699) do (
        findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
        if !errorlevel! equ 0 (
            set "AV1_FOUND=1"
            echo [INFO] AV1 1080p Format ID %%F detected
        )
    )
    if "!AV1_FOUND!"=="1" (
        set "FINAL_CODEC=AV1"
    ) else (
        rem Check for VP9 format IDs (248, 303, 247, 302)
        set "VP9_FOUND=0"
        for %%F in (248 303 247 302) do (
            findstr /r "^%%F[ 	]" "!TEMP_FULL_FORMAT!" >nul 2>&1
            if !errorlevel! equ 0 (
                set "VP9_FOUND=1"
                echo [INFO] VP9 Format ID %%F detected
            )
        )
        rem Also check for vp09 codec string as fallback
        if "!VP9_FOUND!"=="0" (
            findstr /i "vp09 vp9" "!TEMP_FULL_FORMAT!" | findstr /v "243 278 242" >nul 2>&1
            if !errorlevel! equ 0 (
                set "VP9_FOUND=1"
                echo [INFO] VP9 codec detected via codec string
            )
        )
        if "!VP9_FOUND!"=="1" (
            set "FINAL_CODEC=VP9"
        ) else (
            rem Check for H.264 codec (avc1)
            findstr /i "avc1" "!TEMP_FULL_FORMAT!" >nul 2>&1
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
    echo Quality: HIGHEST AVAILABLE - Premium Format Detected
) else if "!FINAL_CODEC!"=="AV1" (
    echo Action in Main Program: Download + Re-encode to H.265
    echo Quality: EXCELLENT - AV1 1080p Codec Detected
) else if "!FINAL_CODEC!"=="VP9" (
    echo Action in Main Program: Download WITHOUT Re-encoding
    echo Quality: EXCELLENT - VP9 Codec ^(skip re-encode policy^)
) else if "!FINAL_CODEC!"=="H264" (
    echo Action in Main Program: Download WITHOUT Re-encoding
    echo Quality: GOOD - Standard H.264 Codec
) else (
    echo Action in Main Program: Standard Download
    echo Quality: VARIABLE
)

if exist "!TEMP_FULL_FORMAT!" del "!TEMP_FULL_FORMAT!"
if exist "!TEMP_FULL_FORMAT!.debug" del "!TEMP_FULL_FORMAT!.debug"
echo.
pause
goto MAIN_MENU