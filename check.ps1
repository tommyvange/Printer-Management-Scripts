param (
    [string]$PrinterName,
    [bool]$Logging = $false
)

# Path to configuration file
$configFilePath = "$PSScriptRoot\config.json"

# Initialize configuration variable
$config = $null

# Check if configuration file exists and load it
if (Test-Path $configFilePath) {
    $config = Get-Content -Path $configFilePath | ConvertFrom-Json
}

# Use parameters from the command line or fall back to config file values
if (-not $PrinterName) { $PrinterName = $config.PrinterName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }

# Validate that all parameters are provided
if (-not $PrinterName) { Write-Error "PrinterName is required but not provided."; exit 1 }

# Determine log file path
$logFilePath = "$env:TEMP\printer_check_log_$PrinterName.txt"

# Start transcript logging if enabled
if ($Logging) {
    Start-Transcript -Path $logFilePath
}

try {
    # Check if the printer exists
    $printerExists = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue

    if ($printerExists) {
        Write-Output "Detected"
        exit 0
    } else {
        Write-Output "NotDetected"
        exit 1
    }
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Stop transcript logging if enabled
    if ($Logging) {
        Stop-Transcript
    }
}
