#NoEnv
SendMode Input
#SingleInstance Ignore

; Main function that opens all folders in tabs
OpenAllFolders() {
    ; Timing constants
    LONG_WAIT   := 2000
    MED_WAIT    := 1000
    SHORT_WAIT  := 450
    QUICK_WAIT  := 200
    
    ; Define folder paths directly in the function
    folderArray := []
    folderArray.Push("D:\Chunky's Master Folder External Drive")
    folderArray.Push("Downloads")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Video Specific Assets and Footage\LIMC video\Images")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Video Specific Assets and Footage\LIMC video\Video")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Video Specific Assets and Footage\LIMC video\Footage and Audio Clips")
    folderArray.Push("E:\Chunky's Master Folder\Snipping Tool and Screenshots\Screenshots")
    folderArray.Push("E:\Chunky's Master Folder\Chunky Photoshop Folder\Final Project")
    folderArray.Push("E:\Chunky's Master Folder\Recordings")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets\Universal Video Assets")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets\Universal Image Assets")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets\Music")
    folderArray.Push("D:\Chunky's Master Folder External Drive\Chunky Premiere Pro Folder\Universal Assets\Universal Audio Assets\SFX")
    folderArray.Push("E:\Chunky's Master Folder\Chunky Audition Folder\Final Recordings")
    folderArray.Push("E:\Chunky's Master Folder\Chunky After Effects Folder\Final Projects")
    
    ; Start File Explorer
    Run, explorer.exe
    WinActivate, ahk_exe explorer.exe
    Sleep, LONG_WAIT
    
    ; Open each folder in a new tab
    totalFolders := folderArray.Length()
    Loop, % totalFolders
    {
        currentIndex := A_Index
        folderPath := folderArray[currentIndex]
        isLastFolder := (currentIndex = totalFolders)
        
        ; Focus address bar and navigate to folder
        SendInput, !d
        Sleep, QUICK_WAIT
        SendInput, % folderPath
        Sleep, QUICK_WAIT
        SendInput, {Enter}
        Sleep, SHORT_WAIT
        
        ; Only create new tab if it's NOT the last folder
        if (!isLastFolder) {
            SendInput, ^t
            Sleep, SHORT_WAIT
        }
        
        ; Slightly longer wait after the first folder to ensure stability
        if (currentIndex = 1) {
            Sleep, MED_WAIT
        }
    }
}

; Always register the hotkey, even when included
^+Home::OpenAllFolders()

; Optional: Keep the exit hotkey for standalone use
^+Escape::ExitApp