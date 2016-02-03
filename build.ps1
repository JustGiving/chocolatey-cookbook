param([string]$task)
$ErrorActionPreference = "Stop"

if ((Test-Path ".\nuget.exe") -eq $false)
{
	$webClient = new-object net.webclient
	$webClient.DownloadFile('https://github.com/OwainPerry/nuget.commandline/raw/master/NuGet.exe','nuget.exe')
}

.\nuget.exe install psake  -ExcludeVersion -OutputDirectory "pkgs"
.\nuget.exe install  cookbookbuilder -Source "http://nuget.prod.justgiving.service:1337/nuget/packages" -ExcludeVersion -OutputDirectory "pkgs" -Version 1.0.0.39

Import-Module '.\pkgs\psake\tools\psake.psm1';
if($task -eq $null)
{
   $task = "Default"
}
Invoke-psake  .\pkgs\cookbookbuilder\default.ps1 -t $task

