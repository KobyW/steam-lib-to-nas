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
        "/NP",       # No progress - reduces log noise
        "/NDL",      # No directory list - reduces log noise
        "/TEE"       # Output to console and log file
    )
    
    robocopy @robocopyArgs
    
    if ($LASTEXITCODE -ge 8) {
        Write-Host "Warning: Robocopy encountered errors while syncing $source" -ForegroundColor Yellow
    }
    else {
        Write-Host "Successfully synced $source" -ForegroundColor Green
    }
}

# Main script

# Set the path to your configuration file
$configPath = ".\config.ini"

# Read the configuration
$config = Read-ConfigFile $configPath

if (-not $config.Destination) {
    Write-Host "Error: Destination path not specified in the configuration file." -ForegroundColor Red
    exit 1
}

if ($config.Sources.Count -eq 0) {
    Write-Host "Error: No source directories specified in the configuration file." -ForegroundColor Red
    exit 1
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