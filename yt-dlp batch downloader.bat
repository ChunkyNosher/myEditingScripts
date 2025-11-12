@echo off
setlocal EnableDelayedExpansion

set "LIST_FILE=yt_download_list.txt"
set "VIDEO_DIR_FILE=video_dir.txt"
set "AUDIO_DIR_FILE=audio_dir.txt"
set "THUMBNAIL_DIR_FILE=thumbnail_dir.txt"
set "BROWSER_FILE=browser_choice.txt"
set "TEMP_FORMAT_FILE=temp_format_check.txt"

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
echo.
echo Starting processing with !PROFILE! profile...
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
pause
goto MAIN_MENU

:DOWNLOAD_AND_ENCODE
setlocal enabledelayedexpansion
set "VIDEO_URL=%~1"
echo Processing: !VIDEO_URL!
yt-dlp --list-formats "!VIDEO_URL!" --cookies-from-browser !BROWSER_CHOICE! 2>nul > "!TEMP_FORMAT_FILE!"
set "CODEC_TYPE=H264"
findstr /i "premium" "!TEMP_FORMAT_FILE!" >nul 2>&1
if !errorlevel! equ 0 (
	set "CODEC_TYPE=PREMIUM"
	echo   Detected: Premium Bitrate
) else (
	findstr /i "av01" "!TEMP_FORMAT_FILE!" | findstr /v "243 278 394 242 395 396 244 397" >nul 2>&1
	if !errorlevel! equ 0 (
		set "CODEC_TYPE=AV1"
		echo   Detected: AV1 Codec
	) else (
		findstr /i "vp09 vp9" "!TEMP_FORMAT_FILE!" | findstr /v "243 278 394 242 395 396 244 397" >nul 2>&1
		if !errorlevel! equ 0 (
			set "CODEC_TYPE=VP9"
			echo   Detected: VP9 Codec
		) else (
			findstr /i "avc1" "!TEMP_FORMAT_FILE!" >nul 2>&1
			if !errorlevel! equ 0 (
				set "CODEC_TYPE=H264"
				echo   Detected: H.264 - Skipping re-encode
			)
		)
	)
)
if "!CODEC_TYPE!"=="H264" (
	echo   Downloading H.264 only...
	yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s H264.%%(ext)s" "!VIDEO_URL!"
	if !errorlevel! equ 0 (
		endlocal
		set /a SUCCESS+=1
		set /a H264_SKIPPED+=1
		exit /b
	) else (
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="PREMIUM" (
	if "!MODE!"=="NOENC" (
		echo   Downloading Premium only...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s PREMIUM.%%(ext)s" "!VIDEO_URL!"
	) else (
		echo   Downloading Premium and re-encoding to H.265...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s PREMIUM_!MODE!.%%(ext)s" "!VIDEO_URL!"
	)
	if !errorlevel! equ 0 (
		endlocal
		set /a SUCCESS+=1
		set /a PREMIUM_ENCODED+=1
		exit /b
	) else (
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="AV1" (
	if "!MODE!"=="NOENC" (
		echo   Downloading AV1 only...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s AV1.%%(ext)s" "!VIDEO_URL!"
	) else (
		echo   Downloading AV1 and re-encoding to H.265...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s AV1_!MODE!.%%(ext)s" "!VIDEO_URL!"
	)
	if !errorlevel! equ 0 (
		endlocal
		set /a SUCCESS+=1
		set /a AV1VP9_ENCODED+=1
		exit /b
	) else (
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if "!CODEC_TYPE!"=="VP9" (
	if "!MODE!"=="NOENC" (
		echo   Downloading VP9 only...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress -o "!DOWNLOAD_DIR!\%%(title)s VP9.%%(ext)s" "!VIDEO_URL!"
	) else (
		echo   Downloading VP9 and re-encoding to H.265...
		yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 --cookies-from-browser !BROWSER_CHOICE! --progress --postprocessor-args "!FFMPEG_ARGS!" -o "!DOWNLOAD_DIR!\%%(title)s VP9_!MODE!.%%(ext)s" "!VIDEO_URL!"
	)
	if !errorlevel! equ 0 (
		endlocal
		set /a SUCCESS+=1
		set /a AV1VP9_ENCODED+=1
		exit /b
	) else (
		endlocal
		set /a FAILED+=1
		exit /b
	)
)
if exist "!TEMP_FORMAT_FILE!" del "!TEMP_FORMAT_FILE!"
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
echo.
set /p "NEW_LINK=Enter URL (leave blank to skip): "
if not "!NEW_LINK!"=="" (
	echo !NEW_LINK!>>"%LIST_FILE%"
	echo Link added!
)
echo.
pause
goto MAIN_MENU

:OPEN_FORMAT_CHECKER
start "" "yt-dlp-format-checker.bat"
goto MAIN_MENU

:END
endlocal
exit /b
