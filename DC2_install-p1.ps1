$NomMachine = Read-Host "Nom de la Machine"
$IPMachine  = Read-Host "IP de la Machine"
$IP_DC1     = Read-Host "DNS de référence du DC1"
$Passerelle = Read-Host "IP de la Paserelle"

Write-Host "Configuration du Réseau" -ForegroundColor Cyan
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $IPMachine -PrefixLength 24 -DefaultGateway $Passerelle -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $IP_DC1

Write-Host "Rennomer la Machine" -ForegroundColor Yellow
Rename-Computer -NewName $NomMachine -Force -Restart
