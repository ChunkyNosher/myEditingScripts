# format_detector.ps1
# Purpose: Parse yt-dlp JSON output and detect video format availability
# Usage: powershell -ExecutionPolicy Bypass -File format_detector.ps1 <json_file_path>
#
# Detects format categories:
# - Premium bitrate formats (above 720p): 356, 616, 721, 774 -> Re-encode
# - AV1 formats above 720p: 399, 699, 400, 700, 401, 701, 402, 571 -> Re-encode
# - VP9 formats (non-premium): Don't re-encode
# - H.264/AVC formats: Don't re-encode

param(
    [Parameter(Mandatory=$true)]
    [string]$JsonFile
)

# Exit codes for error handling
$EXIT_SUCCESS = 0
$EXIT_FILE_NOT_FOUND = 1
$EXIT_INVALID_JSON = 2

# Check if JSON file exists
if (-not (Test-Path $JsonFile)) {
    Write-Error "JSON file not found: $JsonFile"
    exit $EXIT_FILE_NOT_FOUND
}

# Read and parse JSON
try {
    $jsonContent = Get-Content $JsonFile -Raw -Encoding UTF8
    $videoInfo = $jsonContent | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON: $_"
    exit $EXIT_INVALID_JSON
}

# Initialize detection flags
$premiumDetected = $false
$av1HighResDetected = $false
$vp9Detected = $false
$h264Detected = $false

# Track specific format IDs found
$foundFormatIds = @()
$premiumFormatIds = @()
$av1FormatIds = @()

# Define format ID lists based on youtube-format-ids.md

# Premium format IDs (above 720p, require YouTube Premium + Cookies)
# 356: VP9 1080p Premium (HTTPS) - Primary Premium format
# 616: VP9 1080p Premium (m3u8/HLS) - Deprecated Aug 2025 but still check
# 721: AV1 1080p 60fps Premium - Testing phase
# 774: Opus 256kbps Premium audio
$premiumFormats = @("356", "616", "721", "774")

# AV1 format IDs above 720p (1080p and higher) - Should be re-encoded
# 1080p: 399 (30fps), 699 (60fps HFR)
# 1440p: 400 (30fps), 700 (60fps HFR)
# 4K: 401 (30fps), 701 (60fps HFR)
# 8K: 402, 571 (60fps HFR variants)
$av1HighResFormats = @("399", "699", "400", "700", "401", "701", "402", "571")

# VP9 format IDs at 720p and 1080p (non-premium) - DON'T re-encode
# 247: 720p 30fps, 302: 720p 60fps HFR
# 248: 1080p 30fps, 303: 1080p 60fps HFR
# 612: 720p 60fps m3u8 variant
# Also higher res VP9: 271 (1440p), 308 (1440p 60fps), 313 (4K), 315 (4K 60fps), 272 (8K)
$vp9Formats = @("247", "302", "248", "303", "612", "271", "308", "313", "315", "272")

# Low quality VP9 formats to exclude from generic VP9 detection (720p and below not worth re-encoding anyway)
# 242: 240p, 243: 360p, 244: 480p, 278: 144p, 598: 144p rare variant
$vp9LowQualityFormats = @("242", "243", "244", "278", "598")

# Premium VP9 format IDs (should not be counted as regular VP9)
$premiumVp9Formats = @("356", "616")

# Check for formats array
if ($videoInfo.formats) {
    foreach ($format in $videoInfo.formats) {
        $formatId = $format.format_id
        $height = $format.height

        # Skip if no video codec (audio-only formats)
        if ($format.vcodec -eq "none") {
            # Still check for premium audio format 774
            if ($formatId -eq "774") {
                $premiumDetected = $true
                $premiumFormatIds += $formatId
            }
            continue
        }

        # Premium format IDs: 356, 616, 721 (video), 774 (audio handled above)
        if ($formatId -in @("356", "616", "721")) {
            $premiumDetected = $true
            $premiumFormatIds += $formatId
            $foundFormatIds += $formatId
        }

        # AV1 formats above 720p
        # Check by format ID first
        if ($formatId -in $av1HighResFormats) {
            $av1HighResDetected = $true
            $av1FormatIds += $formatId
            $foundFormatIds += $formatId
        }
        # Also check by codec string for AV1 above 720p (height > 720)
        elseif ($format.vcodec -and $format.vcodec -match "av01" -and $height -and $height -gt 720) {
            $av1HighResDetected = $true
            if ($formatId -notin $av1FormatIds) {
                $av1FormatIds += $formatId
                $foundFormatIds += $formatId
            }
        }

        # VP9 formats (non-premium) - check by format ID or codec
        if ($formatId -in $vp9Formats) {
            $vp9Detected = $true
        }
        elseif ($format.vcodec -and $format.vcodec -match "vp0?9" -and $formatId -notin $vp9LowQualityFormats -and $formatId -notin $premiumVp9Formats) {
            # VP9 codec detected but not premium formats
            $vp9Detected = $true
        }

        # H.264 formats - check by codec
        if ($format.vcodec -and $format.vcodec -match "avc1") {
            $h264Detected = $true
        }
    }
}

# Output results in batch-friendly format (KEY=VALUE)
Write-Output "PREMIUM_DETECTED=$([int]$premiumDetected)"
Write-Output "AV1_HIGHRES_DETECTED=$([int]$av1HighResDetected)"
Write-Output "VP9_DETECTED=$([int]$vp9Detected)"
Write-Output "H264_DETECTED=$([int]$h264Detected)"

# Output found format IDs as comma-separated lists
$premiumIdList = $premiumFormatIds -join ","
$av1IdList = $av1FormatIds -join ","
$allFormatIdList = $foundFormatIds -join ","

Write-Output "PREMIUM_FORMAT_IDS=$premiumIdList"
Write-Output "AV1_FORMAT_IDS=$av1IdList"
Write-Output "FORMAT_IDS=$allFormatIdList"

exit $EXIT_SUCCESS
