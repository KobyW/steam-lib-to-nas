# Steam Library Sync Script

# Function to read the configuration file
function Read-ConfigFile {
    param (
        [string]$configPath
    )
    
    $config = @{
        Destination = ""
        Sources = @()
    }
    
    if (!(Test-Path $configPath)) {
        throw "Configuration file not found at $configPath"
    }
    
    $content = Get-Content $configPath
    
    $section = ""
    foreach ($line in $content) {
        if ($line -match '^\[(.+)\]$') {
            $section = $matches[1]
        }
        elseif ($line -match '^(.+?)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            if ($section -eq "Paths" -and $key -eq "Destination") {
                $config.Destination = $value
            }
            elseif ($section -eq "Sources" -and $key -match '^Source\d+$') {
                $config.Sources += $value
            }
        }
    }
    
    return $config
}

# Function to sync directories
function Sync-Directory {
    param (
        [string]$source,
        [string]$destination
    )
    
    Write-Host "Syncing $source to $destination..."
    
    # Use robocopy for efficient syncing
    $robocopyArgs = @(
        $source,
        $destination,
        "/E",        # Copy subdirectories, including empty ones
        "/ZB",       # Use restartable mode; if access denied use backup mode
        "/DCOPY:DAT",# Copy directory timestamps
        "/R:5",      # Number of retries
        "/W:5",      # Wait time between retries
        "/MT:16",    # Use 16 threads for multi-threaded copying
        "/XJ",       # Exclude junction points
        "/XD", "SteamappsWorkshop",  # Exclude Workshop folder
        "/V",        # Produce verbose output
        "/TEE"       # Output to console and log file
    )
    
    $robocopyOutput = & robocopy @robocopyArgs
    $robocopyExitCode = $LASTEXITCODE

    Write-Host "Robocopy Output:"
    $robocopyOutput | ForEach-Object { Write-Host $_ }
    
    switch ($robocopyExitCode) {
        0 { Write-Host "No files were copied. No failure was encountered. No files were mismatched. The files already exist in the destination directory; therefore, the copy operation was skipped." -ForegroundColor Green }
        1 { Write-Host "All files were copied successfully." -ForegroundColor Green }
        2 { Write-Host "There are some additional files in the destination directory that are not present in the source directory. No files were copied." -ForegroundColor Yellow }
        3 { Write-Host "Some files were copied. Additional files were present. No failure was encountered." -ForegroundColor Yellow }
        5 { Write-Host "Some files were copied. Some files were mismatched. No failure was encountered." -ForegroundColor Yellow }
        6 { Write-Host "Additional files and mismatched files exist. No files were copied and no failures were encountered. This means that the files already exist in the destination directory." -ForegroundColor Yellow }
        7 { Write-Host "Files were copied, a file mismatch was present, and additional files were present." -ForegroundColor Yellow }
        8 { Write-Host "Several files did not copy." -ForegroundColor Red }
        default { Write-Host "Unexpected Robocopy exit code: $robocopyExitCode" -ForegroundColor Red }
    }
}

# Main script

try {
    # Set the path to your configuration file
    $configPath = "config.ini"

    # Read the configuration
    $config = Read-ConfigFile $configPath

    if (-not $config.Destination) {
        throw "Destination path not specified in the configuration file."
    }

    if ($config.Sources.Count -eq 0) {
        throw "No source directories specified in the configuration file."
    }

    # Create the destination directory if it doesn't exist
    if (!(Test-Path $config.Destination)) {
        New-Item -ItemType Directory -Path $config.Destination | Out-Null
    }

    # Sync each source directory
    foreach ($source in $config.Sources) {
        if (Test-Path $source) {
            Sync-Directory $source $config.Destination
        }
        else {
            Write-Host "Warning: Source directory $source does not exist. Skipping." -ForegroundColor Yellow
        }
    }

    Write-Host "Sync process completed." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
finally {
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}