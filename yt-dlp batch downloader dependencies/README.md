# yt-dlp Batch Downloader Dependencies

This folder contains configuration files and logs for the yt-dlp batch downloader script.

## Files

| File | Description |
|------|-------------|
| `yt_download_list.txt` | List of YouTube URLs to download |
| `video_dir.txt` | Video download directory path |
| `audio_dir.txt` | Audio download directory path |
| `thumbnail_dir.txt` | Thumbnail download directory path |
| `browser_choice.txt` | Browser used for cookie extraction (firefox, chrome, edge) |
| `temp_format_check.txt` | Temporary file for format detection (auto-deleted) |

## Subdirectories

| Directory | Description |
|-----------|-------------|
| `logs/` | Encoding session logs with timestamps and processing details |

## Migration

When you run the batch script, it will automatically:
1. Create this folder structure if it doesn't exist
2. Move any existing configuration files from the root directory to this folder
3. Move existing logs to the `logs/` subdirectory
