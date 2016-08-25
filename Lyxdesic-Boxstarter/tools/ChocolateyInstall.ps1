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

    $redistsandnets = @("DotNet3.5", "DotNet4.6", "vcredist2005", "vcredist2008", "vcredist2010", "vcredist2012", "vcredist2013", "vcredist2015")
    foreach ($redistandnet in $redistsandnets) {
        $check = choco list $redistandnet --localonly
        if ($check -eq "0 packages installed.") {
            choco install $redistandnet -y
            $check = $null
        } else {
            choco upgrade $redistandnet -y
        }
    }
    if (Test-PendingReboot) { Invoke-Reboot }
    choco install -y Microsoft-Hyper-V-All -source windowsfeatures

    $apps = @("slack", "SourceCodePro", "visualstudiocode", "7zip.install", "rufus","sysinternals", "paint.net","winmerge","cmder","poshgit","pester","mobaxterm","linkshellextension","rktools.2003","git-credential-winstore","vagrant","greenshot","autohotkey","lessmsi","lockhunter","rdcman","pscx" )
    foreach ($app in $apps) {
        $check = choco list $app --localonly
        if ($check -eq "0 packages installed.") {
            choco install $app -y
            $check = $null
        } else {
            choco upgrade $app -y
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
    #choco install -y windows-sdk-10 
    if (Test-PendingReboot) { Invoke-Reboot }
    $2apps = @("visualstudio2015community","NugetPackageExplorer", "windbg", "googlechrome", "javaruntime","autoit.commandline","spotify","lastpass")
    foreach ($2app in $2apps) {
        $check = choco list $2app --localonly
        if ($2app -eq "0 packages installed.") {
            choco install $2app -y
            $check = $null
        } else {
            choco upgrade $2app -y
        }
    }
    #vs extensions
    Install-ChocolateyVsixPackage PowerShellTools https://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/199313/3/PowerShellTools.14.0.vsix
    Install-ChocolateyVsixPackage NuGet.Tools https://visualstudiogallery.msdn.microsoft.com/5d345edc-2e2d-4a9c-b73b-d53956dc458d/file/146283/13/NuGet.Tools.vsix
    Install-ChocolateyVsixPackage WebExtensionPack https://visualstudiogallery.msdn.microsoft.com/f3b504c6-0095-42f1-a989-51d5fc2a8459/file/186606/24/Web%20Extension%20Pack%20v1.6.51.vsix
    Install-ChocolateyVsixPackage T4Toolbox https://visualstudiogallery.msdn.microsoft.com/34b6d489-afbc-4d7b-82c3-dded2b726dbc/file/165481/4/T4Toolbox.14.0.0.76.vsix

    choco feature enable -n=checksumFiles
    if (!(Test-Path "$env:appdata\Code\User\Snippets")) { New-Item "$env:appdata\Code\User\Snippets" -ItemType Directory -Force }
    if (Test-Path "C:\tools\cmder\config") { Write-Warning "Overwriting user-profile.ps1 for cmder" }
    Copy-Item -Path "$toolsDir\user-profile.ps1" -Destination "C:\tools\cmder\config\user-profile.ps1" -Force

    Copy-Item -Path "$toolsDir\ConEmu.xml" -Destination "$env:SystemDrive\tools\cmder\vendor\conemu-maximus5\ConEmu.xml"
    Copy-Item -Path "$toolsDir\json.json" -Destination "$ENV:APPDATA\Code\User\Snippets\json.json"
    Copy-Item -Path "$toolsDir\powershell.json" -Destination "$ENV:APPDATA\Code\User\Snippets\powershell.json"
    Copy-Item -Path "$toolsDir\shellscript.json" -Destination "$ENV:APPDATA\Code\User\Snippets\shellscript.json"
    Copy-Item -Path "$toolsDir\PinTo10.exe" -Destination "$env:SystemDrive\tools\PinTo10.exe"
    #Copy-Item -Path "$toolsDir\pinitem.cmd" -Destination "$env:SystemDrive\tools\pinitem.cmd"
    cmd /c "$env:SystemDrive\tools\PinTo10.exe /PTFOL:`"${env:ProgramFiles(x86)}\Google\Chrome\Application`" /PTFILE:`"chrome.exe`""
    cmd /c "$env:SystemDrive\tools\PinTo10.exe /PTFOL:`"$env:SystemDrive\tools\cmder`" /PTFILE:`"Cmder.exe`""
    #$ENV:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar
    #Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    #Install-ChocolateyPinnedTaskBarItem "$env:ChocolateyToolsLocation\cmder\Cmder.exe"
    
    Write-ChocolateySuccess 'Lyxdesic-Boxstarter'

    } catch {
    Write-ChocolateyFailure 'Lyxdesic-Boxstarter' $($_.Exception.Message)
    throw
    }