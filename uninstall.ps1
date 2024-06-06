# Developed by:
# ___________                           ___________.__          __________                        __   
# \__    ___/___   _____   _____ ___.__.\__    ___/|  |__   ____\______   \ ____ _____    _______/  |_ 
#   |    | /  _ \ /     \ /     <   |  |  |    |   |  |  \_/ __ \|    |  _// __ \\__  \  /  ___/\   __\
#   |    |(  <_> )  Y Y  \  Y Y  \___  |  |    |   |   Y  \  ___/|    |   \  ___/ / __ \_\___ \  |  |  
#   |____| \____/|__|_|  /__|_|  / ____|  |____|   |___|  /\___  >______  /\___  >____  /____  > |__|  
#
# Version: 1.0

param (
    [string]$PortName,
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
if (-not $PortName) { $PortName = $config.PortName }
if (-not $PrinterName) { $PrinterName = $config.PrinterName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }

# Validate that all parameters are provided
if (-not $PortName) { Write-Error "PortName is required but not provided."; exit 1 }
if (-not $PrinterName) { Write-Error "PrinterName is required but not provided."; exit 1 }

# Start transcript logging if enabled
if ($Logging) {
    $logFilePath = "$env:TEMP\printer_uninstall_log_${PrinterName}_$($PortName).txt"
    Start-Transcript -Path $logFilePath
}

try {
    # Check if the printer exists
    $printerExists = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue

    # Check if the printer port exists
    $portExists = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue

    # If the printer exists, remove it
    if ($printerExists) {
        Remove-Printer -Name $PrinterName
        if ($?) {
            Write-Output "Printer '$PrinterName' removed successfully."
        } else {
            Write-Output "Error: Failed to remove printer '$PrinterName'."
            exit 1
        }
    } else {
        Write-Output "Printer '$PrinterName' does not exist. Skipping removal."
    }

    # If the port exists, check if any other printers are using the port and remove them
    if ($portExists) {
        $printersUsingPort = Get-Printer | Where-Object { $_.PortName -eq $PortName }
        foreach ($printer in $printersUsingPort) {
            Remove-Printer -Name $printer.Name
            if ($?) {
                Write-Output "Printer '$($printer.Name)' using port '$PortName' removed successfully."
            } else {
                Write-Output "Error: Failed to remove printer '$($printer.Name)' using port '$PortName'."
                exit 1
            }
        }

        # Remove the printer port
        Remove-PrinterPort -Name $PortName
        if ($?) {
            Write-Output "Printer port '$PortName' removed successfully."
            exit 0
        } else {
            Write-Output "Error: Failed to remove printer port '$PortName'."
            exit 1
        }
    } else {
        Write-Output "Printer port '$PortName' does not exist. Skipping removal."
        exit 0
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
