
#Replace 20160621 for nothing ''
Get-ChildItem -Filter "*.20160621*" -Recurse | Rename-Item -NewName {$_.name -replace '.20160621','' }


#Replacing substring
#http://stackoverflow.com/questions/5095782/find-character-position-and-update-file-name
Get-Childitem -Filter "*CDR.2016*" | Rename-Item -newname '
  { $_.name -replace $_.name.SubString($_.name.IndexOf("_"), '
       $_.name.LastIndexOf(".") - $_.name.IndexOf("_") ),''}

#OR
#This worked as expected
Get-Childitem -path .\* -Exclude *Z -Filter *CDR.2016* | Rename-Item -newname { $_.name -replace $_.name.SubString($_.name.IndexOf("2"), $_.name.LastIndexOf("6") - $_.name.IndexOf("2") ),''}
Get-Childitem -path .\* -Exclude *Z -Filter *CDR.2016* | Rename-Item -newname { $_.name -replace $_.name.SubString($_.name.IndexOf("6"), $_.name.Length - $_.name.IndexOf("6") ),''}       

#Exclude everything from .2016 onwards 
Get-Childitem -path .\* -Exclude *Z -Filter *CDR.2016* | Rename-Item -newname { $_.name -replace $_.name.SubString($_.name.IndexOf(".2016"), $_.name.LastIndexOf("") + 1 - $_.name.IndexOf(".2016")),''}       



#PS Microsoft.PowerShell.Core\FileSystem::\\GAL-CV-FP01\Users\RochePaul\Comms\OrangeWholesale\StagingFiles\zip> 
#To filter and exclude, we should pass the full path.
Get-Childitem -path \\GAL-CV-FP01\Users\RochePaul\Comms\OrangeWholesale\StagingFiles\zip\* -Exclude *Z -Filter *CDR.2016*
#OR
Get-Childitem -path .\* -Exclude *Z -Filter *CDR.2016*


#Extract each file individualy
$Zips = Get-ChildItem -filter "*.Z" -path \\GAL-CV-FP01\Users\RochePaul\Comms\OrangeWholesale\StagingFiles\zip\ -Recurse
$Destination = '\\GAL-CV-FP01\Users\RochePaul\Comms\OrangeWholesale\StagingFiles\zip\'
$WinRar = "C:\Program Files\WinRAR\winrar.exe"

foreach ($zip in $Zips)
{
&$Winrar x $zip.FullName $Destination
Get-Process winrar | Wait-Process
}