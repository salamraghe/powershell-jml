Import-Module ActiveDirectory
$changes = Import-Csv C:\Lab\changes.csv
foreach ($c in $changes) {
$id = $c.SamAccountName
Remove-ADGroupMember -Identity $c.OldGroup -Members $id -Confirm:$false
if ($c.Action -eq "Move") {
Add-ADGroupMember -Identity $c.NewGroup -Members $id
Write-Host "Moved $id to $($c.NewGroup)"
}
if ($c.Action -eq "Leave") {
Disable-ADAccount -Identity $id
Write-Host "Disabled $id"
 }
}
