try {
 
    # Boxstarter options
    $Boxstarter.RebootOk=$true # Allow reboots?
    $Boxstarter.NoPassword=$false # Is this a machine with no login password?
    $Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot
 
    # Basic setup
    Update-ExecutionPolicy RemoteSigned
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
    #Enable-RemoteDesktop
    Disable-InternetExplorerESC
    Set-TaskbarOptions -Size Small -UnLock -Dock Top
 
    if (Test-PendingReboot) { Invoke-Reboot }
 
    # Update Windows and reboot if necessary
    Install-WindowsUpdate -AcceptEula
    if (Test-PendingReboot) { Invoke-Reboot }
    choco feature disable -n=checksumFiles
    cinst -y DotNet3.5 
    if (Test-PendingReboot) { Invoke-Reboot }
    cinst -y dotnet4.6
    if (Test-PendingReboot) { Invoke-Reboot }

    cinst -y vcredist2005 
    cinst -y vcredist2008 
    cinst -y vcredist2010 
    cinst -y vcredist2012 
    cinst -y vcredist2013 
    cinst -y vcredist2015 
    if (Test-PendingReboot) { Invoke-Reboot }
    cinst -y Microsoft-Hyper-V-All -source windowsfeatures

    cinst -y slack 
    cinst -y SourceCodePro 
    cinst -y visualstudiocode 
    cinst -y 7zip.install 
    cinst -y sysinternals 
    cinst -y paint.net 
    cinst -y winmerge 
    cinst -y cmder 
    cinst -y poshgit 
    cinst -y pester 
    cinst -y mobaxterm 
    cinst -y linkshellextension  
    cinst -y rktools.2003 
    cinst -y rsat 
    cinst -y git-credential-winstore 
    cinst -y vagrant 
    cinst -y greenshot 
    cinst -y autohotkey 
    cinst -y lessmsi 
    cinst -y lockhunter 
    cinst -y rdcman 
    cinst -y pscx 

    # Windows SDK 7 or 8
    cinst -y windows-sdk-10 
    if (Test-PendingReboot) { Invoke-Reboot }

    #Other dev tools
    cinst -y NugetPackageExplorer 
    cinst -y windbg 

    #Browsers
    cinst -y googlechrome 
    cinst -y firefox 

    #Other essential tools
    cinst -y adobereader 
    cinst -y javaruntime 
    cinst -y java.jdk 

    choco feature enable -n=checksumFiles
    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    
    Write-ChocolateySuccess 'Lyxdesic-Boxstarter'

    } catch {
    Write-ChocolateyFailure 'Lyxdesic-Boxstarter' $($_.Exception.Message)
    throw
    }

