$User = "CELTRAK\rgoncalezadmin"
$PWord = ConvertTo-SecureString –String "Ligeiro6!" –AsPlainText -Force
$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $User, $PWord

"istrue,servername" | Out-File C:\Users\rgoncalezadmin\Desktop\test.txt

$Servers = "CEL-SQLDEV","CEL-SQLU4","CEL-SQLU9"
ForEach ($Server in $Servers) {

$hostname = (Invoke-Command -ComputerName $Server -Scriptblock {hostname} -Credential $Credential)
$isTrue = (Invoke-Command -ComputerName $Server -Scriptblock {(Get-Date).IsDaylightSavingTime()} -Credential $Credential)
"$isTrue,$hostname" | Out-File C:\Users\rgoncalezadmin\Desktop\test.txt -Append

}


$User = "local\dmzadmin"
$PWord = ConvertTo-SecureString –String "G*Qup7aru" –AsPlainText -Force
$Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $User, $PWord

$Servers = "cel-gprs01.celtrak.dmz"
ForEach ($Server in $Servers) {

$hostname = (Invoke-Command -ComputerName $Server -Scriptblock {hostname} -Credential $Credential)
$isTrue = (Invoke-Command -ComputerName $Server -Scriptblock {(Get-Date).IsDaylightSavingTime()} -Credential $Credential)
"$isTrue,$hostname" | Out-File C:\Users\rgoncalezadmin\Desktop\test.txt -Append

}