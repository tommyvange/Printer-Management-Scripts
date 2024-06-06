################################################################################
# Project: tommyvange/printer-management-scripts
# File: install.ps1
# Developer: Tommy Vange Rød
# License: GPL 3.0 License
#
# This file is part of "Printer Management Scripts".
#
# "Printer Management Scripts" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html#license-text>.
################################################################################

param (
    [string]$PrinterHostAddress,
    [string]$PortName,
    [string]$DriverName,
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
if (-not $PrinterHostAddress) { $PrinterHostAddress = $config.PrinterHostAddress }
if (-not $PortName) { $PortName = $config.PortName }
if (-not $DriverName) { $DriverName = $config.DriverName }
if (-not $PrinterName) { $PrinterName = $config.PrinterName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }

# Validate that all parameters are provided
if (-not $PrinterHostAddress) { Write-Error "PrinterHostAddress is required but not provided."; exit 1 }
if (-not $PortName) { Write-Error "PortName is required but not provided."; exit 1 }
if (-not $DriverName) { Write-Error "DriverName is required but not provided."; exit 1 }
if (-not $PrinterName) { Write-Error "PrinterName is required but not provided."; exit 1 }

# Start transcript logging if enabled
if ($Logging) {
    $logFilePath = "$env:TEMP\printer_install_log_${PrinterName}_$($PortName).txt"
    Start-Transcript -Path $logFilePath
}

try {
    # Check if the printer port already exists
    $portExists = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue

    # Check if the printer already exists
    $printerExists = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue

    # If the port exists, verify that it points to the correct IP address
    if ($portExists) {
        if ($portExists.PrinterHostAddress -eq $PrinterHostAddress) {
            Write-Output "Printer port '$PortName' already exists and points to the correct IP."
        } else {
            Write-Output "Error: Printer port '$PortName' exists but points to a different IP."
            exit 1
        }
    }

    # If the printer exists, remove it and its associated port
    if ($printerExists) {
        $existingPortName = $printerExists.PortName
        Write-Output "Printer '$PrinterName' already exists. Removing existing printer and port '$existingPortName'."
        Remove-Printer -Name $PrinterName
        if ($?) {
            Write-Output "Printer '$PrinterName' removed successfully."
        } else {
            Write-Output "Error: Failed to remove existing printer '$PrinterName'."
            exit 1
        }
        Remove-PrinterPort -Name $existingPortName
        if ($?) {
            Write-Output "Printer port '$existingPortName' removed successfully."
        } else {
            Write-Output "Error: Failed to remove existing printer port '$existingPortName'."
            exit 1
        }
    }

    # Add the printer port if it doesn't exist or was just removed
    if (-not $portExists -or $printerExists) {
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterHostAddress
        if ($?) {
            Write-Output "Printer port '$PortName' added successfully."
        } else {
            Write-Output "Error: Failed to add printer port '$PortName'."
            exit 1
        }
    }

    # Add the printer
    Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
    if ($?) {
        Write-Output "Printer '$PrinterName' added successfully."
        exit 0
    } else {
        Write-Output "Error: Failed to add printer '$PrinterName'."
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
