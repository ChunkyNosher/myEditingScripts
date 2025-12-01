@echo off
setlocal EnableDelayedExpansion

rem ==============================
rem Dependencies folder setup
rem ==============================
set "DEPS_FOLDER=yt-dlp batch downloader dependencies"
set "LOGS_FOLDER=%DEPS_FOLDER%\logs"

rem Create dependencies and logs folders if they don't exist
if not exist "%DEPS_FOLDER%" mkdir "%DEPS_FOLDER%"
if not exist "%LOGS_FOLDER%" mkdir "%LOGS_FOLDER%"

rem Define file paths inside dependencies folder
set "LIST_FILE=%DEPS_FOLDER%\yt_download_list.txt"
set "VIDEO_DIR_FILE=%DEPS_FOLDER%\video_dir.txt"
set "AUDIO_DIR_FILE=%DEPS_FOLDER%\audio_dir.txt"
set "THUMBNAIL_DIR_FILE=%DEPS_FOLDER%\thumbnail_dir.txt"
set "BROWSER_FILE=%DEPS_FOLDER%\browser_choice.txt"
set "TEMP_FORMAT_FILE=%DEPS_FOLDER%\temp_format_check.txt"

rem Migrate old files to new location if they exist in the current directory
if exist "yt_download_list.txt" (
	if not exist "%LIST_FILE%" move "yt_download_list.txt" "%LIST_FILE%" >nul 2>&1
)
if exist "video_dir.txt" (
	if not exist "%VIDEO_DIR_FILE%" move "video_dir.txt" "%VIDEO_DIR_FILE%" >nul 2>&1
)
if exist "audio_dir.txt" (
	if not exist "%AUDIO_DIR_FILE%" move "audio_dir.txt" "%AUDIO_DIR_FILE%" >nul 2>&1
)
if exist "thumbnail_dir.txt" (
	if not exist "%THUMBNAIL_DIR_FILE%" move "thumbnail_dir.txt" "%THUMBNAIL_DIR_FILE%" >nul 2>&1
)
if exist "browser_choice.txt" (
	if not exist "%BROWSER_FILE%" move "browser_choice.txt" "%BROWSER_FILE%" >nul 2>&1
)
if exist "temp_format_check.txt" (
	del "temp_format_check.txt" >nul 2>&1
)

rem Move old logs folder if it exists
if exist "yt-dlp batch downloader logs" (
	if not exist "%LOGS_FOLDER%" (
		move "yt-dlp batch downloader logs" "%LOGS_FOLDER%" >nul 2>&1
	) else (
		rem Copy contents to new location
		xcopy /E /Y "yt-dlp batch downloader logs\*" "%LOGS_FOLDER%\" >nul 2>&1
		rd /S /Q "yt-dlp batch downloader logs" >nul 2>&1
	)
)

:MAIN_MENU
cls
echo ==============================
echo YouTube Download Manager
echo ==============================
echo.
if exist "%LIST_FILE%" (
	for /f %%C in ('find /c /v "" ^< "%LIST_FILE%"') do set "COUNT=%%C"
) else (
	set "COUNT=0"
)
echo Current list has !COUNT! links
echo.
echo ==== ENCODING OPTIONS ====
echo 1. GPU H.265 Encoding (Choose Profile)
echo 2. CPU H.265 Encoding (Choose Profile)
echo 3. Download Highest Quality (No Re-encoding)
echo.
echo ==== UTILITIES ====
echo 4. Open Format Checker
echo 5. Download all links (standard)
echo 6. Download audio only
echo 7. Download thumbnails only
echo.
echo ==== SETTINGS ====
echo Q. Set video download directory
echo W. Set audio download directory
echo E. Set thumbnail download directory
echo R. Set browser for Premium access
echo T. View list
echo Y. Clear list
echo U. Add links to list
echo I. Exit
echo.
choice /c 1234567QWERTYUI /n /m "Choose an option: "
set CHOICE=%errorlevel%
if %CHOICE%==1 goto GPU_MENU
if %CHOICE%==2 goto CPU_MENU
if %CHOICE%==3 goto NO_ENCODING
if %CHOICE%==4 goto OPEN_FORMAT_CHECKER
if %CHOICE%==5 goto DOWNLOAD_STANDARD
if %CHOICE%==6 goto DOWNLOAD_AUDIO
if %CHOICE%==7 goto DOWNLOAD_THUMBNAILS
if %CHOICE%==8 goto SET_VIDEO_DIR
if %CHOICE%==9 goto SET_AUDIO_DIR
if %CHOICE%==10 goto SET_THUMBNAIL_DIR
if %CHOICE%==11 goto SET_BROWSER
if %CHOICE%==12 goto VIEW_LIST
if %CHOICE%==13 goto CLEAR_LIST
if %CHOICE%==14 goto ADD_LINKS
if %CHOICE%==15 goto END
goto MAIN_MENU

:GPU_MENU
cls
echo ==============================
echo GPU H.265 Encoding Profiles
echo ==============================
echo.
echo 1. Standard Quality
echo 2. High Quality
echo 3. Live Action
echo 4. Animation
echo 5. Mixed Video
echo 6. Back to Main Menu
echo.
choice /c 123456 /n /m "Choose GPU profile: "
set GPU_CHOICE=%errorlevel%
if %GPU_CHOICE%==1 (
	set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -cq 18 -b:v 0 -rc vbr -multipass 2 -spatial-aq 1 -temporal-aq 1 -c:a aac -b:a 128k"
	set "PROFILE=STANDARD"
	goto GPU_ENCODING
)
if %GPU_CHOICE%==2 (
	set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -cq 18 -rc vbr -rc-lookahead 32 -refs 32 -spatial-aq 1 -temporal-aq 1 -c:a aac -b:a 128k"
	set "PROFILE=HQ"
	goto GPU_ENCODING
)
if %GPU_CHOICE%==3 (
	set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -rc vbr_hq -cq 6 -qmin 0 -qmax 12 -rc-lookahead 32 -refs 32 -bf 4 -spatial-aq 1 -temporal-aq 1 -aq-strength 12 -b_ref_mode disabled -c:a aac -b:a 128k"
	set "PROFILE=LIVEACTION"
	goto GPU_ENCODING
)
if %GPU_CHOICE%==4 (
	set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -rc vbr_hq -cq 6 -qmin 0 -qmax 12 -rc-lookahead 32 -refs 32 -bf 3 -spatial-aq 1 -temporal-aq 0 -aq-strength 10 -c:a aac -b:a 128k"
	set "PROFILE=ANIMATION"
	goto GPU_ENCODING
)
if %GPU_CHOICE%==5 (
	set "FFMPEG_ARGS=-c:v hevc_nvenc -preset p7 -rc vbr_hq -cq 8 -qmin 1 -qmax 14 -rc-lookahead 32 -refs 32 -bf 3 -spatial-aq 1 -temporal-aq 1 -aq-strength 8 -c:a aac -b:a 128k"
	set "PROFILE=MIXEDVIDEO"
	goto GPU_ENCODING
)
if %GPU_CHOICE%==6 goto MAIN_MENU
goto GPU_MENU

:GPU_ENCODING
cls
if not exist "%BROWSER_FILE%" (
	echo Browser not set!
	pause
	goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo GPU H.265 Encoding - !PROFILE! Profile
set "MODE=GPU"
goto PROCESS_LIST

:CPU_MENU
cls
echo ==============================
echo CPU H.265 Encoding Profiles
echo ==============================
echo.
echo 1. Medium Preset
echo 2. Slow Preset
echo 3. Live Action
echo 4. Animation
echo 5. Mixed Video
echo 6. Back to Main Menu
echo.
choice /c 123456 /n /m "Choose CPU profile: "
set CPU_CHOICE=%errorlevel%
if %CPU_CHOICE%==1 (
	set "FFMPEG_ARGS=-c:v libx265 -preset medium -crf 19 -x265-params aq-mode=3:aq-strength=1.0:psy-rd=1.0:psy-rdoq=1.0:rd=4:rdoq-level=1:subme=5:merange=57:bframes=4:b-adapt=1:ref=4:rc-lookahead=100:weightb=1 -c:a aac -b:a 128k"
	set "PROFILE=MEDIUM"
	goto CPU_ENCODING
)
if %CPU_CHOICE%==2 (
	set "FFMPEG_ARGS=-c:v libx265 -preset slow -crf 16 -x265-params aq-mode=3:aq-strength=1.5:psy-rd=2.0:psy-rdoq=2.0:rd=6:rdoq-level=2:subme=7:merange=57:bframes=8:b-adapt=2:ref=6:rc-lookahead=250:weightb=1:rskip=2:rskip-edge-threshold=2 -c:a aac -b:a 128k"
	set "PROFILE=SLOW"
	goto CPU_ENCODING
)
if %CPU_CHOICE%==3 (
	set "FFMPEG_ARGS=-c:v libx265 -preset veryslow -crf 16 -x265-params aq-mode=3:aq-strength=1.5:psy-rd=2.0:psy-rdoq=2.0:rd=6:rdoq-level=2:subme=7:merange=57:bframes=8:b-adapt=2:ref=6:rc-lookahead=250:weightb=1:rskip=2:rskip-edge-threshold=2 -c:a aac -b:a 128k"
	set "PROFILE=LIVEACTION"
	goto CPU_ENCODING
)
if %CPU_CHOICE%==4 (
	set "FFMPEG_ARGS=-c:v libx265 -preset veryslow -crf 15 -x265-params aq-mode=3:aq-strength=1.2:psy-rd=2.0:psy-rdoq=2.0:rd=6:rdoq-level=2:subme=7:merange=57:bframes=6:b-adapt=2:ref=6:rc-lookahead=250:weightb=1:rskip=1:rskip-edge-threshold=2:deblock=-1,-1 -c:a aac -b:a 128k"
	set "PROFILE=ANIMATION"
	goto CPU_ENCODING
)
if %CPU_CHOICE%==5 (
	set "FFMPEG_ARGS=-c:v libx265 -preset slow -crf 17 -x265-params aq-mode=3:aq-strength=1.3:psy-rd=2.0:psy-rdoq=2.0:rd=6:rdoq-level=2:subme=7:merange=57:bframes=7:b-adapt=2:ref=6:rc-lookahead=250:weightb=1:rskip=2:rskip-edge-threshold=2 -c:a aac -b:a 128k"
	set "PROFILE=MIXEDVIDEO"
	goto CPU_ENCODING
)
if %CPU_CHOICE%==6 goto MAIN_MENU
goto CPU_MENU

:CPU_ENCODING
cls
if not exist "%BROWSER_FILE%" (
	echo Browser not set!
	pause
	goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo CPU H.265 Encoding - !PROFILE! Profile
set "MODE=CPU"
goto PROCESS_LIST

:NO_ENCODING
cls
if not exist "%BROWSER_FILE%" (
	echo Browser not set!
	pause
	goto MAIN_MENU
)
set /p BROWSER_CHOICE=<"%BROWSER_FILE%"
echo Download Highest Quality - No Re-encoding
set "FFMPEG_ARGS="
set "MODE=NOENC"
set "PROFILE=NONE"
goto PROCESS_LIST

:PROCESS_LIST
if not exist "%LIST_FILE%" (
	echo No links in list!
	pause
	goto MAIN_MENU
)
if exist "%VIDEO_DIR_FILE%" (
	set /p DOWNLOAD_DIR=<"%VIDEO_DIR_FILE%"
	if not exist "!DOWNLOAD_DIR!" mkdir "!DOWNLOAD_DIR!"
) else (
	set "DOWNLOAD_DIR=%CD%"
)
set SUCCESS=0
set FAILED=0
set PREMIUM_ENCODED=0
set AV1VP9_ENCODED=0
set H264_SKIPPED=0

rem Create timestamp for log file
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "LOG_DATE=%%c-%%a-%%b"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "LOG_TIME=%%a-%%b"
set "LOG_FILE=%LOGS_FOLDER%\encoding_!LOG_DATE!_!LOG_TIME!_!MODE!_!PROFILE!.txt"

rem Start logging
echo ================================ > "!LOG_FILE!"
echo Encoding Session Log >> "!LOG_FILE!"
echo Date: !LOG_DATE! Time: !LOG_TIME! >> "!LOG_FILE!"
echo Mode: !MODE! Profile: !PROFILE! >> "!LOG_FILE!"
echo Browser: !BROWSER_CHOICE! >> "!LOG_FILE!"
echo Download Directory: !DOWNLOAD_DIR! >> "!LOG_FILE!"
echo ================================ >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

echo.
echo Starting processing with !PROFILE! profile...
echo Logging to: !LOG_FILE!
echo.
for /f "usebackq delims=" %%U in ("%LIST_FILE%") do (
	call :DOWNLOAD_AND_ENCODE "%%U"
)
echo.
echo ================================
echo Download Summary
echo ================================
echo Total Processed: !SUCCESS!
echo Total Failed: !FAILED!
echo Premium Re-encoded: !PREMIUM_ENCODED!
echo AV1/VP9 Re-encoded: !AV1VP9_ENCODED!
echo H.264 Skipped: !H264_SKIPPED!
echo Location: !DOWNLOAD_DIR!
echo ================================

rem Write summary to log
echo. >> "!LOG_FILE!"
echo ================================ >> "!LOG_FILE!"
echo Download Summary >> "!LOG_FILE!"
echo ================================ >> "!LOG_FILE!"
echo Total Processed: !SUCCESS! >> "!LOG_FILE!"
echo Total Failed: !FAILED! >> "!LOG_FILE!"
echo Premium Re-encoded: !PREMIUM_ENCODED! >> "!LOG_FILE!"
echo AV1/VP9 Re-encoded: !AV1VP9_ENCODED! >> "!LOG_FILE!"
echo H.264 Skipped: !H264_SKIPPED! >> "!LOG_FILE!"
echo Location: !DOWNLOAD_DIR! >> "!LOG_FILE!"
echo ================================ >> "!LOG_FILE!"
echo Log saved to: !LOG_FILE!
pause
goto MAIN_MENU

:DOWNLOAD_AND_ENCODE
setlocal enabledelayedexpansion
set "VIDEO_URL=%~1"
echo Processing: !VIDEO_URL!
echo. >> "!LOG_FILE!"
echo Processing: !VIDEO_URL! >> "!LOG_FILE!"
echo Timestamp: %date% %time% >> "!LOG_FILE!"

rem Get format list with verbose output to capture premium detection
yt-dlp --list-formats "!VIDEO_URL!" --cookies-from-browser !BROWSER_CHOICE! -v 2>"!TEMP_FORMAT_FILE!.debug" > "!TEMP_FORMAT_FILE!"

rem Check for YouTube Premium subscription detection in verbose output
set "HAS_PREMIUM_SUB=0"
findstr /i /c:"Detected YouTube Premium" "!TEMP_FORMAT_FILE!.debug" >nul 2>&1
if !errorlevel! equ 0 (
	set "HAS_PREMIUM_SUB=1"
	echo   Detected: YouTube Premium subscription active
	echo   Detected: YouTube Premium subscription active >> "!LOG_FILE!"
)

rem Check for premium format IDs (356, 616, 774 are premium-exclusive formats)
set "CODEC_TYPE=H264"
set "PREMIUM_DETECTED=0"

rem Check for premium format IDs in the format list
findstr /r "^356[ 	]" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)
findstr /r "^616[ 	]" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)
findstr /r "^774[ 	]" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)

rem Also check with leading spaces for format IDs
findstr /c:" 356 " "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)
findstr /c:" 616 " "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)
findstr /c:" 774 " "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)

rem Check for premium in MORE INFO column (high bitrate indicator)
findstr /i "premium" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "PREMIUM_DETECTED=1"
)

if "!PREMIUM_DETECTED!"=="1" (
	set "CODEC_TYPE=PREMIUM"
	echo   Detected: Premium Bitrate Format
	echo   Detected: Premium Bitrate Format >> "!LOG_FILE!"
) else (
	rem Check for AV1 codec (excluding low quality format IDs)
	findstr /i "av01" "!TEMP_FORMAT_FILE!" | findstr /v "243 278 394 242 395 396 244 397" >nul 2>&1
	if !errorlevel! equ 0 (
		set "CODEC_TYPE=AV1"
		echo   Detected: AV1 Codec
		echo   Detected: AV1 Codec >> "!LOG_FILE!"
	) else (
		rem Check for VP9 codec
		findstr /i "vp09 vp9" "!TEMP_FORMAT_FILE!" | findstr /v "243 278 394 242 395 396 244 397" >nul 2>&1
		if !errorlevel! equ 0 (
			set "CODEC_TYPE=VP9"
			echo   Detected: VP9 Codec
			echo   Detected: VP9 Codec >> "!LOG_FILE!"
		) else (
			rem Check for H.264 codec
			findstr /i "avc1" "!TEMP_FORMAT_FILE!" >nul 2>&1
			if !errorlevel! equ 0 (
				set "CODEC_TYPE=H264"
				echo   Detected: H.264 - Skipping re-encode
				echo   Detected: H.264 - Skipping re-encode >> "!LOG_FILE!"
			)
		)
	)
)
if "!CODEC_TYPE!"=="H264" (
	echo   Downloading H.264 only...
	echo   Action: Downloading H.264 only >> "!LOG_FILE!"
	yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s H264.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	if !errorlevel! equ 0 (
		echo   Status: SUCCESS >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a SUCCESS+=1
		set /a H264_SKIPPED+=1
		exit /b
	) else (
		echo   Status: FAILED >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="PREMIUM" (
	if "!MODE!"=="NOENC" (
		echo   Downloading Premium only...
		echo   Action: Downloading Premium only ^(no re-encode^) >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s PREMIUM.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	) else (
		echo   Downloading Premium and re-encoding to H.265...
		echo   Action: Downloading Premium and re-encoding to H.265 >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s PREMIUM_!MODE!.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	)
	if !errorlevel! equ 0 (
		echo   Status: SUCCESS >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a SUCCESS+=1
		set /a PREMIUM_ENCODED+=1
		exit /b
	) else (
		echo   Status: FAILED >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="AV1" (
	if "!MODE!"=="NOENC" (
		echo   Downloading AV1 only...
		echo   Action: Downloading AV1 only ^(no re-encode^) >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s AV1.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	) else (
		echo   Downloading AV1 and re-encoding to H.265...
		echo   Action: Downloading AV1 and re-encoding to H.265 >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s AV1_!MODE!.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	)
	if !errorlevel! equ 0 (
		echo   Status: SUCCESS >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a SUCCESS+=1
		set /a AV1VP9_ENCODED+=1
		exit /b
	) else (
		echo   Status: FAILED >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="VP9" (
	if "!MODE!"=="NOENC" (
		echo   Downloading VP9 only...
		echo   Action: Downloading VP9 only ^(no re-encode^) >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s VP9.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	) else (
		echo   Downloading VP9 and re-encoding to H.265...
		echo   Action: Downloading VP9 and re-encoding to H.265 >> "!LOG_FILE!"
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s VP9_!MODE!.%%(ext)s" "!VIDEO_URL!" 2>>"!LOG_FILE!"
	)
	if !errorlevel! equ 0 (
		echo   Status: SUCCESS >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a SUCCESS+=1
		set /a AV1VP9_ENCODED+=1
		exit /b
	) else (
		echo   Status: FAILED >> "!LOG_FILE!"
		if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if exist "!TEMP_FORMAT_FILE!" del "!TEMP_FORMAT_FILE!"
if exist "!TEMP_FORMAT_FILE!.debug" del "!TEMP_FORMAT_FILE!.debug"
endlocal
exit /b

:DOWNLOAD_STANDARD
cls
echo Download All Links (Standard)
echo.
choice /c YN /n /m "Continue? (Y/N): "
if !errorlevel! equ 2 goto MAIN_MENU
if exist "%VIDEO_DIR_FILE%" (
	set /p DOWNLOAD_DIR=<"%VIDEO_DIR_FILE%"
	if not exist "!DOWNLOAD_DIR!" mkdir "!DOWNLOAD_DIR!"
) else (
	set "DOWNLOAD_DIR=%CD%"
)
set SUCCESS=0
set FAILED=0
for /f "usebackq delims=" %%U in ("%LIST_FILE%") do (
	yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --progress -o "!DOWNLOAD_DIR!\%%(title)s.%%(ext)s" "%%U"
	if !errorlevel! equ 0 (
		set /a SUCCESS+=1
	) else (
		set /a FAILED+=1
	)
)
echo.
echo Downloads completed. Success: !SUCCESS!, Failed: !FAILED!
pause
goto MAIN_MENU

:DOWNLOAD_AUDIO
cls
echo Download Audio Only
echo.
choice /c YN /n /m "Continue? (Y/N): "
if !errorlevel! equ 2 goto MAIN_MENU
if exist "%AUDIO_DIR_FILE%" (
	set /p DOWNLOAD_DIR=<"%AUDIO_DIR_FILE%"
	if not exist "!DOWNLOAD_DIR!" mkdir "!DOWNLOAD_DIR!"
) else (
	set "DOWNLOAD_DIR=%CD%"
)
set SUCCESS=0
set FAILED=0
for /f "usebackq delims=" %%U in ("%LIST_FILE%") do (
	yt-dlp -f bestaudio --extract-audio --audio-format mp3 -o "!DOWNLOAD_DIR!\%%(title)s.%%(ext)s" "%%U"
	if !errorlevel! equ 0 (
		set /a SUCCESS+=1
	) else (
		set /a FAILED+=1
	)
)
echo.
echo Audio downloads completed. Success: !SUCCESS!, Failed: !FAILED!
pause
goto MAIN_MENU

:DOWNLOAD_THUMBNAILS
cls
echo Download Thumbnails Only
echo.
choice /c YN /n /m "Continue? (Y/N): "
if !errorlevel! equ 2 goto MAIN_MENU
if exist "%THUMBNAIL_DIR_FILE%" (
	set /p DOWNLOAD_DIR=<"%THUMBNAIL_DIR_FILE%"
	if not exist "!DOWNLOAD_DIR!" mkdir "!DOWNLOAD_DIR!"
) else (
	set "DOWNLOAD_DIR=%CD%"
)
set SUCCESS=0
set FAILED=0
for /f "usebackq delims=" %%U in ("%LIST_FILE%") do (
	yt-dlp --skip-download --write-thumbnail -o "!DOWNLOAD_DIR!\%%(title)s" "%%U"
	if !errorlevel! equ 0 (
		set /a SUCCESS+=1
	) else (
		set /a FAILED+=1
	)
)
echo.
echo Thumbnail downloads completed. Success: !SUCCESS!, Failed: !FAILED!
pause
goto MAIN_MENU

:SET_VIDEO_DIR
cls
set /p "NEW_DIR=Enter video download directory: "
if not "!NEW_DIR!"=="" (
	echo !NEW_DIR!>"%VIDEO_DIR_FILE%"
	echo Video directory set!
)
echo.
pause
goto MAIN_MENU

:SET_AUDIO_DIR
cls
set /p "NEW_DIR=Enter audio download directory: "
if not "!NEW_DIR!"=="" (
	echo !NEW_DIR!>"%AUDIO_DIR_FILE%"
	echo Audio directory set!
)
echo.
pause
goto MAIN_MENU

:SET_THUMBNAIL_DIR
cls
set /p "NEW_DIR=Enter thumbnail download directory: "
if not "!NEW_DIR!"=="" (
	echo !NEW_DIR!>"%THUMBNAIL_DIR_FILE%"
	echo Thumbnail directory set!
)
echo.
pause
goto MAIN_MENU

:SET_BROWSER
cls
echo Choose browser:
echo 1. Firefox
echo 2. Chrome
echo 3. Edge
echo.
choice /c 123 /n /m "Choose browser (1-3): "
set BROWSER_CHOICE=%errorlevel%
if %BROWSER_CHOICE%==1 set "BROWSER=firefox"
if %BROWSER_CHOICE%==2 set "BROWSER=chrome"
if %BROWSER_CHOICE%==3 set "BROWSER=edge"
echo !BROWSER!>"%BROWSER_FILE%"
echo Browser set to: !BROWSER!
echo.
pause
goto MAIN_MENU

:VIEW_LIST
cls
echo ==============================
echo Current Download List
echo ==============================
echo.
if exist "%LIST_FILE%" (
	type "%LIST_FILE%"
) else (
	echo List is empty
)
echo.
pause
goto MAIN_MENU

:CLEAR_LIST
cls
choice /c YN /n /m "Clear list? (Y/N): "
if !errorlevel! equ 1 (
	del "%LIST_FILE%"
	echo List cleared
)
echo.
pause
goto MAIN_MENU

:ADD_LINKS
cls
echo Add Links to Download List
echo ==============================
echo Enter URLs one at a time, pressing Enter after each.
echo Type 'done' or leave blank to finish adding links.
echo ==============================
echo.
:ADD_LINKS_LOOP
set "NEW_LINK="
set /p "NEW_LINK=Enter URL: "
if "!NEW_LINK!"=="" goto ADD_LINKS_DONE
if /i "!NEW_LINK!"=="done" goto ADD_LINKS_DONE
echo !NEW_LINK!>>"%LIST_FILE%"
echo   Link added!
goto ADD_LINKS_LOOP
:ADD_LINKS_DONE
echo.
echo Finished adding links.
pause
goto MAIN_MENU

:OPEN_FORMAT_CHECKER
start "" "yt-dlp-format-checker.bat"
goto MAIN_MENU

:END
endlocal
exit /b
