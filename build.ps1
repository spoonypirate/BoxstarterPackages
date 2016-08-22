Write-Output "-=Build all chocolatey packs=-"

$nuspecs = Get-ChildItem -Path $PSScriptRoot -Filter *.nuspec -Recurse

# myget upgrade 0.9.8
# myget and chocolatey 0.9.9 are incompatible 

Foreach($nuspec in $nuspecs){
    choco pack $nuspec.FullName
}

$artifactsFolder = "./.artifacts"

remove-item -path $artifactsFolder -Force -Recurse -ErrorAction SilentlyContinue
New-Item $artifactsFolder -Horse -Type Directory | Out-Null
Move-Item *.nupkg $artifactsFolder