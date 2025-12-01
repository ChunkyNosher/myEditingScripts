@echo off
setlocal EnableDelayedExpansion

rem ==============================
rem Dependencies folder setup
rem ==============================
set "DEPS_FOLDER=yt-dlp batch downloader dependencies"

rem Use dependencies folder for files
set "LIST_FILE=%DEPS_FOLDER%\yt_download_list.txt"
set "BROWSER_FILE=%DEPS_FOLDER%\browser_choice.txt"
set "JSON_FILE=%DEPS_FOLDER%\temp_format_check.json"
set "PS_SCRIPT=%DEPS_FOLDER%\format_detector.ps1"

rem Fallback to old location if dependencies folder doesn't exist
if not exist "%DEPS_FOLDER%" (
    set "LIST_FILE=yt_download_list.txt"
    set "BROWSER_FILE=browser_choice.txt"
    set "JSON_FILE=temp_format_check.json"
    set "PS_SCRIPT=format_detector.ps1"
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
if not exist "%PS_SCRIPT%" (
    echo format_detector.ps1 not found!
    echo Please ensure the PowerShell script exists in the dependencies folder.
    pause
    goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo ==============================
echo Checking Formats for All Videos
echo With JSON-Based Codec Detection
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
    
    rem Get JSON info for reliable detection
    echo Fetching video information...
    yt-dlp -J "%%U" --cookies-from-browser !BROWSER_CHOICE! --quiet > "!JSON_FILE!" 2>nul
    
    if not exist "!JSON_FILE!" (
        echo [ERROR] Failed to retrieve video information
        echo.
        pause >nul
        goto :NEXT_VIDEO_ALL
    )
    
    echo.
    echo === CODEC DETECTION ^(JSON-Based^) ===
    echo.
    
    rem Initialize detection variables
    set "PREMIUM_DETECTED=0"
    set "AV1_HIGHRES_DETECTED=0"
    set "VP9_DETECTED=0"
    set "H264_DETECTED=0"
    set "PREMIUM_FORMAT_IDS="
    set "AV1_FORMAT_IDS="
    
    rem Execute PowerShell and capture output
    for /f "usebackq tokens=1,2 delims==" %%A in (`powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" "!JSON_FILE!" 2^>nul`) do (
        set "%%A=%%B"
    )
    
    rem Clean up JSON file
    if exist "!JSON_FILE!" del "!JSON_FILE!"
    
    rem Display detection results
    if not "!PREMIUM_FORMAT_IDS!"=="" (
        echo [INFO] Premium Format IDs: !PREMIUM_FORMAT_IDS!
    )
    if not "!AV1_FORMAT_IDS!"=="" (
        echo [INFO] AV1 High-Res Format IDs: !AV1_FORMAT_IDS!
    )
    if "!VP9_DETECTED!"=="1" echo [INFO] VP9 codec detected
    if "!H264_DETECTED!"=="1" echo [INFO] H.264 codec detected
    
    rem Determine final codec based on priority
    set "FINAL_CODEC=UNKNOWN"
    if "!PREMIUM_DETECTED!"=="1" (
        set "FINAL_CODEC=PREMIUM"
    ) else if "!AV1_HIGHRES_DETECTED!"=="1" (
        set "FINAL_CODEC=AV1"
    ) else if "!VP9_DETECTED!"=="1" (
        set "FINAL_CODEC=VP9"
    ) else if "!H264_DETECTED!"=="1" (
        set "FINAL_CODEC=H264"
    )
    
    echo.
    echo [CODEC DETECTION RESULT]
    echo.
    echo Detected Codec: !FINAL_CODEC!
    echo.
    
    if "!FINAL_CODEC!"=="PREMIUM" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: HIGHEST AVAILABLE - Premium Format ^(above 720p^) Detected
    ) else if "!FINAL_CODEC!"=="AV1" (
        echo Action in Main Program: Download + Re-encode to H.265
        echo Quality: EXCELLENT - AV1 High-Resolution ^(above 720p^) Detected
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
    
    echo.
    echo ==============================
    echo Press any key to continue to next video...
    echo ==============================
    pause >nul
    :NEXT_VIDEO_ALL
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
if not exist "%PS_SCRIPT%" (
    echo format_detector.ps1 not found!
    echo Please ensure the PowerShell script exists in the dependencies folder.
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

rem Get JSON info for reliable detection
echo Fetching video information...
yt-dlp -J "!SINGLE_URL!" --cookies-from-browser !BROWSER_CHOICE! --quiet > "!JSON_FILE!" 2>nul

if not exist "!JSON_FILE!" (
    echo.
    echo [ERROR] Failed to retrieve video information
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo === CODEC DETECTION ^(JSON-Based^) ===
echo.

rem Initialize detection variables
set "PREMIUM_DETECTED=0"
set "AV1_HIGHRES_DETECTED=0"
set "VP9_DETECTED=0"
set "H264_DETECTED=0"
set "PREMIUM_FORMAT_IDS="
set "AV1_FORMAT_IDS="

rem Execute PowerShell and capture output
for /f "usebackq tokens=1,2 delims==" %%A in (`powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" "!JSON_FILE!" 2^>nul`) do (
    set "%%A=%%B"
)

rem Clean up JSON file
if exist "!JSON_FILE!" del "!JSON_FILE!"

rem Display detection results
if not "!PREMIUM_FORMAT_IDS!"=="" (
    echo [INFO] Premium Format IDs: !PREMIUM_FORMAT_IDS!
)
if not "!AV1_FORMAT_IDS!"=="" (
    echo [INFO] AV1 High-Res Format IDs: !AV1_FORMAT_IDS!
)
if "!VP9_DETECTED!"=="1" echo [INFO] VP9 codec detected
if "!H264_DETECTED!"=="1" echo [INFO] H.264 codec detected

rem Determine final codec based on priority
set "FINAL_CODEC=UNKNOWN"
if "!PREMIUM_DETECTED!"=="1" (
    set "FINAL_CODEC=PREMIUM"
) else if "!AV1_HIGHRES_DETECTED!"=="1" (
    set "FINAL_CODEC=AV1"
) else if "!VP9_DETECTED!"=="1" (
    set "FINAL_CODEC=VP9"
) else if "!H264_DETECTED!"=="1" (
    set "FINAL_CODEC=H264"
)

echo.
echo [CODEC DETECTION RESULT]
echo.
echo Detected Codec: !FINAL_CODEC!
echo.

if "!FINAL_CODEC!"=="PREMIUM" (
    echo Action in Main Program: Download + Re-encode to H.265
    echo Quality: HIGHEST AVAILABLE - Premium Format ^(above 720p^) Detected
) else if "!FINAL_CODEC!"=="AV1" (
    echo Action in Main Program: Download + Re-encode to H.265
    echo Quality: EXCELLENT - AV1 High-Resolution ^(above 720p^) Detected
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

echo.
pause
goto MAIN_MENU