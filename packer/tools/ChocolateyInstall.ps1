try {
 
    # Boxstarter options
    $Boxstarter.RebootOk=$true # Allow reboots?
    $Boxstarter.NoPassword=$false # Is this a machine with no login password?
    $Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot
    
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    
    cinst -y golang
    New-Item -Path "$env:SystemDrive\go\dev" -Force
    Set-EnvironmentVariable gopath "$env:SystemDrive\go\dev"
    Invoke-Reboot
    push-location "$env:gopath"
    go get github.com/mitchellh/packer
    push-location "$env:gopath\src\github.com\mitchellh\packer"
    git remote add hyperv https://github.com/taliesin/packer
    git fetch hyperv
    git checkout hyperv
    go build -o bin/packer.exe

    Write-ChocolateySuccess 'packer'

    } catch {
    Write-ChocolateyFailure 'packer' $($_.Exception.Message)
    throw
    }

