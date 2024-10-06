# Steam Library Sync Script

This PowerShell script allows you to sync multiple Steam library folders to a specified destination, such as a NAS (Network Attached Storage). It's designed to copy only new or changed files, making it suitable for regular backups or syncing between different locations.

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later
- Access to source Steam library folders and destination location

## Setup

1. Clone the repository
2. Create a new folder called `Scripts` in your C: drive (or choose another location).
3. Save the `steam-sync.ps1` script in the `Scripts` folder.
4. Create a configuration file named `config.ini` in the same folder with the following structure:

```ini
[Paths]
Destination=\\Your-NAS\Backup\Steam Library

[Sources]
Source1=C:\Program Files (x86)\Steam\steamapps\common
Source2=D:\SteamLibrary\steamapps\common
# Add more source directories as needed, incrementing the number
# Source3=E:\AnotherSteamLibrary\steamapps\common
```

4. Modify the `Destination` path to point to your desired backup location.
5. Add or remove `Source` entries as needed to include all your Steam library locations.

## Usage

### Manual Execution

1. Open Powershell as admin
2. Navigate to the script's folder
3. Run `.\steam-sync.ps1`
4. Press any key to close the window when the sync is complete.

### Scheduled Task

To run the script automatically on a schedule:

1. Open Task Scheduler (search for it in the Start menu).
2. Click "Create Basic Task" in the Actions panel.
3. Follow the wizard, setting your desired schedule.
4. When you get to the "Action" step:
   - Choose "Start a program"
   - In "Program/script", enter: `powershell.exe`
   - In "Add arguments", enter: `-ExecutionPolicy Bypass -File "C:\Scripts\steam-sync.ps1"`
5. When you get to the "Finish" step:
   - Check "Open the Properties dialog for this task when I click Finish"
   - Click "Finish"
6. When properties open
   - Check "Run whether use is logged on or not"
   - Check "Run with highest privleges"
   - (optional) Under 'Settings" tab: 
       - You can enable "Run task as soon as possible after a scheduled start is missed"
   - Click "OK"

## Troubleshooting

If you encounter errors during the sync process:

1. Check the console output for specific error messages or Robocopy exit codes.
2. Ensure all paths in the `config.ini` file are correct and accessible.
3. Verify that you have the necessary permissions to read from the source directories and write to the destination.
4. If syncing to a NAS, check your network connection and NAS availability.
5. For persistent issues, try running PowerShell as an administrator and execute the script.