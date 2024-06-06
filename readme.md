# Printer Management Scripts

These scripts are designed to install and uninstall network printers on Windows machines. They can read parameters from the command line, a configuration file (`config.json`), or use default values. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

This repository is licensed under the **[GNU General Public License v3.0 (GPLv3)](LICENSE)**.

Developed by **[Tommy Vange Rød](https://github.com/tommyvange)**.


## Configuration

The scripts use a configuration file (`config.json`) to store default values for the printer settings. Here is an example of the configuration file:

``` json
{
	"PrinterHostAddress": "111.22.33.444",
	"PortName": "IT_PRINT",
	"DriverName": "HP Universal Printing PCL 6",
	"PrinterName": "IT",
	"Logging": true
}
```

## Install Script

### Description

The install script adds a printer port and a printer using the specified parameters. It checks if the port and printer already exist and takes appropriate actions to ensure they are correctly configured.

### Usage

To run the install script, use the following command:
``` powershell
.\install.ps1 -PrinterHostAddress "<PrinterHostAddress>" -PortName "<PortName>" -DriverName "<DriverName>" -PrinterName "<PrinterName>" [-Logging $true]
```

### Parameters
-   `PrinterHostAddress`: The IP address of the printer.
-   `PortName`: The name of the printer port.
-   `DriverName`: The name of the printer driver.
-   `PrinterName`: The name of the printer.
-   [Optional] `Logging`: Enables transcript logging if set to `true`.

### Fallback to Configuration File

If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:
``` powershell
.\install.ps1 -PrinterHostAddress "111.22.33.555" -PortName "CUSTOM_PORT" -DriverName "Custom Driver" -PrinterName "Custom Printer" [-Logging $true]
```

To use the default values from the configuration file:
``` powershell
.\install.ps1
```

### Script Workflow

1.  Check if the printer port exists.
2.  If the port exists, verify that it points to the correct IP address.
3.  If the printer exists, remove it and its associated port.
4.  Add the printer port if it doesn't exist or was just removed.
5.  Add the printer.

## Uninstall Script

### Description

The uninstall script removes a specified printer and its associated port. It checks if the printer and port exist before attempting to remove them, ensuring no unnecessary errors are thrown. Additionally, it checks if any other printers are using the specified port and removes them before deleting the port.

### Usage

To run the uninstall script, use the following command:
``` powershell
.\uninstall.ps1 -PortName "<PortName>" -PrinterName "<PrinterName>" [-Logging $true]
``` 

### Parameters

-`PortName`: The name of the printer port.
-`PrinterName`: The name of the printer.
-[Optional] `Logging`: Enables transcript logging if set to `true`.

### Fallback to Configuration File

If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:
``` powershell
.\uninstall.ps1 -PortName "CUSTOM_PORT" -PrinterName "Custom Printer" [-Logging $true]
```

To use the default values from the configuration file:

``` powershell
.\uninstall.ps1
```


### Script Workflow
1.  Check if the printer exists.
2.  If the printer exists, remove it.
3.  Check if any other printers are using the specified port and remove them.
4.  If the port exists, remove it.

## Check Printer Script

### Description

The check printer script verifies if a specified printer exists and outputs "Detected" or "NotDetected". It uses exit codes compatible with Intune: `0` for success (detected) and `1` for failure (not detected).

### Usage

To run the check printer script, use the following command:
``` powershell
.\check.ps1 -PrinterName "<PrinterName>" [-Logging $true]
```

### Parameters
-   `PrinterName`: The name of the printer to check.
-   [Optional] `Logging`: Enables transcript logging if set to `true`.

### Fallback to Configuration File

If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:
``` powershell
.\check.ps1 -PrinterName "Custom Printer" [-Logging $true]
```

To use the default values from the configuration file:

``` powershell
.\check.ps1
```

### Script Workflow
1.  Check if the printer name is provided.
2.  Start transcript logging if enabled.
3.  Check if the printer exists.
4.  Output "Detected" if the printer exists, otherwise output "NotDetected".

## Logging

### Description

Both the install and uninstall scripts support transcript logging to capture detailed information about the script execution. Logging can be enabled via the `-Logging` parameter or the configuration file.

### How It Works

When logging is enabled, the scripts will start a PowerShell transcript at the beginning of the execution and stop it at the end. This transcript will include all commands executed and their output, providing a detailed log of the script's actions.

### Enabling Logging

Logging can be enabled by setting the `-Logging` parameter to `true` when running the script, or by setting the `Logging` property to `true` in the `config.json` file.


### Log File Location

The log files are stored in the temporary directory of the user running the script. The log file names follow the pattern:

-   For the install script: `printer_install_log_<PrinterName>_<PortName>.txt`
-   For the uninstall script: `printer_uninstall_log_<PrinterName>_<PortName>.txt`

Example log file paths:

-   `C:\Users\<Username>\AppData\Local\Temp\printer_install_log_IT_IT_PRINT.txt`
-   `C:\Users\<Username>\AppData\Local\Temp\printer_uninstall_log_IT_IT_PRINT.txt`

**System Account Exception**: When scripts are run as the System account, such as during automated deployments or via certain administrative tools, the log files will be stored in the `C:\Windows\Temp` directory instead of the user's local temporary directory.

## Error Handling

Both scripts include error handling to provide clear messages when parameters are missing or actions fail. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

## Notes

-   Ensure that you have the necessary permissions to add and remove printers and ports on the machine where these scripts are executed.
-   The scripts assume that the printer driver specified is already installed on the machine.

## Troubleshooting

If you encounter any issues, ensure that all parameters are correctly specified and that the printer driver is installed. Check the error messages provided by the scripts for further details on what might have gone wrong.

# GNU General Public License v3.0 (GPLv3)

The  **GNU General Public License v3.0 (GPLv3)**  is a free, copyleft license for software and other creative works. It ensures your freedom to share, modify, and distribute all versions of a program, keeping it free software for everyone.

Full license can be read [here](LICENSE) or at [gnu.org](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text).

## Key Points:

1.  **Freedom to Share and Change:**
    -   You can distribute copies of GPLv3-licensed software.
    -   Access the source code.
    -   Modify the software.
    -   Create new free programs using parts of it.
	
2.  **Responsibilities:**
    -   If you distribute GPLv3 software, pass on the same freedoms to recipients.
    -   Provide the source code.
    -   Make recipients aware of their rights.
	
3.  **No Warranty:**
    -   No warranty for this free software.
    -   Developers protect your rights through copyright and this license.
	
4.  **Marking Modifications:**
    -   Clearly mark modified versions to avoid attributing problems to previous authors.
