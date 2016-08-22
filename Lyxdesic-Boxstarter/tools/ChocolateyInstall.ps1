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
 
    cinst -y DotNet3.5 --allowEmptyChecksums# Not automatically installed with VS 2013. Includes .NET 2.0. Uses Windows Features to install.
    if (Test-PendingReboot) { Invoke-Reboot }
    cinst -y dotnet4.6 --allowEmptyChecksums
    if (Test-PendingReboot) { Invoke-Reboot }

    cinst -y vcredist2005 --allowEmptyChecksums
    cinst -y vcredist2008 --allowEmptyChecksums
    cinst -y vcredist2010 --allowEmptyChecksums
    cinst -y vcredist2012 --allowEmptyChecksums
    cinst -y vcredist2013 --allowEmptyChecksums
    cinst -y vcredist2015 --allowEmptyChecksums
    if (Test-PendingReboot) { Invoke-Reboot }
    cinst -y Microsoft-Hyper-V-All -source windowsfeatures

    cinst -y slack --allowEmptyChecksums
    cinst -y SourceCodePro --allowEmptyChecksums
    cinst -y visualstudiocode --allowEmptyChecksums
    cinst -y 7zip.install --allowEmptyChecksums
    cinst -y sysinternals --allowEmptyChecksums
    cinst -y paint.net --allowEmptyChecksums
    cinst -y winmerge --allowEmptyChecksums
    cinst -y cmder --allowEmptyChecksums
    cinst -y poshgit --allowEmptyChecksums
    cinst -y pester --allowEmptyChecksums
    cinst -y mobaxterm --allowEmptyChecksums
    cinst -y linkshellextension  --allowEmptyChecksums
    cinst -y rktools.2003 --allowEmptyChecksums
    cinst -y rsat --allowEmptyChecksums
    cinst -y git-credential-winstore --allowEmptyChecksums
    cinst -y vagrant --allowEmptyChecksums
    cinst -y greenshot --allowEmptyChecksums
    cinst -y autohotkey --allowEmptyChecksums
    cinst -y lessmsi --allowEmptyChecksums
    cinst -y lockhunter --allowEmptyChecksums
    cinst -y rdcman --allowEmptyChecksums
    cinst -y pscx --allowEmptyChecksums

    # Windows SDK 7 or 8
    cinst -y windows-sdk-10 --allowEmptyChecksums
    if (Test-PendingReboot) { Invoke-Reboot }

    #Other dev tools
    cinst -y NugetPackageExplorer --allowEmptyChecksums
    cinst -y windbg --allowEmptyChecksums

    #Browsers
    cinst -y googlechrome --allowEmptyChecksums
    cinst -y firefox --allowEmptyChecksums

    #Other essential tools
    cinst -y adobereader --allowEmptyChecksums
    cinst -y javaruntime --allowEmptyChecksums
    cinst -y java.jdk --allowEmptyChecksums

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    
    Write-ChocolateySuccess 'Lyxdesic-Boxstarter'

    } catch {
    Write-ChocolateyFailure 'Lyxdesic-Boxstarter' $($_.Exception.Message)
    throw
    }

