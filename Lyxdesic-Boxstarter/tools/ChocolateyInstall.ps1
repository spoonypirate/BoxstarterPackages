try {
 
    # Boxstarter options
    $Boxstarter.RebootOk=$true # Allow reboots?
    $Boxstarter.NoPassword=$false # Is this a machine with no login password?
    $Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot
    
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    # Basic setup
    Update-ExecutionPolicy RemoteSigned
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
    #Enable-RemoteDesktop
    Disable-InternetExplorerESC
    Set-TaskbarOptions -Size Large -Lock -Dock Bottom -Combine Always
 
    if (Test-PendingReboot) { Invoke-Reboot }
 
    # Update Windows and reboot if necessary
    Install-WindowsUpdate -AcceptEula
    if (Test-PendingReboot) { Invoke-Reboot }
    choco feature disable -n=checksumFiles
    choco install -y DotNet3.5 
    if (Test-PendingReboot) { Invoke-Reboot }
    choco install -y dotnet4.6
    if (Test-PendingReboot) { Invoke-Reboot }
    $vcredists = @("vcredist2005", "vcredist2008", "vcredist2010", "vcredist2012", "vcredist2013", "vcredist2015")
    foreach ($vcredist in $vcredists) {
        $check = choco list $vcredist --localonly
        if ($check -eq "0 packages installed.") {
            choco install $vcredist -y
        } else {
            choco upgrade $vcredist --force -y
        }
    }
    if (Test-PendingReboot) { Invoke-Reboot }
    choco install -y Microsoft-Hyper-V-All -source windowsfeatures

    $apps = @("slack", "SourceCodePro", "visualstudiocode", "7zip.install", "rufus","sysinternals", "paint.net","winmerge","cmder","poshgit","pester","mobaxterm","linkshellextension","rktools.2003","git-credential-winstore","vagrant","greenshot","autohotkey","lessmsi","lockhunter","rdcman","pscx" )
    foreach ($app in $apps) {
        $check = choco list $app --localonly
        if ($check -eq "0 packages installed.") {
            choco install $app -y
        } else {
            choco upgrade $app --force -y
        }
    }
    #RSAT is outdated on chocolatey, doesn't work with newest Win10 builds
    <#$checkrsat = choco list rsat --localonly
    if ($checkrsat -eq "0 packages installed.") {
        choco install rsat -y
    } else {
        choco uninstall rsat -y --force
        if (Test-PendingReboot) { Invoke-Reboot }
        choco install rsat -y
    }#>
    choco install -y windows-sdk-10 
    if (Test-PendingReboot) { Invoke-Reboot }

    $2apps = @("NugetPackageExplorer", "windbg", "googlechrome", "adobereader", "javaruntime","autoit.commandline","spotify","lastpass")
    foreach ($2app in $2apps) {
        $check = choco list $2app --localonly
        if ($2app -eq "0 packages installed.") {
            choco install $2app -y
        } else {
            choco upgrade $2app --force -y
        }
    }

    choco feature enable -n=checksumFiles
    
    Copy-Item -Path "$toolsDir\ConEmu.xml" -Destination "$env:ChocolateyToolsLocation\cmder\vendor\conemu-maximus5\ConEmu.xml"
    Copy-Item -Path "$toolsDir\json.json" -Destination "$ENV:APPDATA\Code\User\Snippets\json.json"
    Copy-Item -Path "$toolsDir\powershell.json" -Destination "$ENV:APPDATA\Code\User\Snippets\powershell.json"
    Copy-Item -Path "$toolsDir\shellscript.json" -Destination "$ENV:APPDATA\Code\User\Snippets\shellscript.json"
    
    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    Install-ChocolateyPinnedTaskBarItem "$env:ChocolateyToolsLocation\cmder\Cmder.exe"
    
    Write-ChocolateySuccess 'Lyxdesic-Boxstarter'

    } catch {
    Write-ChocolateyFailure 'Lyxdesic-Boxstarter' $($_.Exception.Message)
    throw
    }

