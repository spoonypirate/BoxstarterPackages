try {
 
    # Boxstarter options
    $Boxstarter.RebootOk=$true # Allow reboots?
    $Boxstarter.NoPassword=$false # Is this a machine with no login password?
    $Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot
    
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    
    cinst DotNet4.5

    #Enable Web Services
    cinst IIS-WebServerRole -source WindowsFeatures
    cinst IIS-ISAPIFilter -source WindowsFeatures
    cinst IIS-ISAPIExtensions -source WindowsFeatures

    #Enable ASP.NET on win 2012/8
    cinst IIS-NetFxExtensibility45 -source WindowsFeatures
    cinst NetFx4Extended-ASPNET45 -source WindowsFeatures
    cinst IIS-ASPNet45 -source WindowsFeatures

    #Enable ASP.NET on win 7/2008R2
    ."$env:windir\microsoft.net\framework\v4.0.30319\aspnet_regiis.exe" -i

    #clean and create application
    Remove-Item c:\web\NugetServer -Recurse -Force -ErrorAction SilentlyContinue
    Mkdir c:\web\NugetServer -ErrorAction SilentlyContinue
    Copy-Item "$(Join-Path (Get-PackageRoot $MyInvocation ) NugetServer)\*" c:\web\NugetServer -Recurse -Force
    Import-Module WebAdministration
    Remove-WebSite -Name "Default Web Site" -ErrorAction SilentlyContinue
    Remove-WebSite -Name NugetServer -ErrorAction SilentlyContinue
    New-WebSite -ID 1 -Name NugetServer -Port 80 -PhysicalPath c:\web\NugetServer -Force

    #Client SKUs need to enable firewall
    netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80
    
    Write-ChocolateySuccess 'NugetServer'

    } catch {
    Write-ChocolateyFailure 'packer' $($_.Exception.Message)
    throw
    }

