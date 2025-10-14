# install-dsc-iis.ps1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Define the DSC configuration
Configuration InstallIIS {
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node 'localhost' {
    WindowsFeature IIS {
      Ensure = 'Present'
      Name   = 'Web-Server'
    }
  }
}

# Output path for compiled MOF
$OutputPath = 'C:\DSC\InstallIIS'

# Compile the configuration (creates the MOF)
InstallIIS -OutputPath $OutputPath

# Apply the configuration and wait until done
Start-DscConfiguration -Path $OutputPath -Wait -Verbose -Force
