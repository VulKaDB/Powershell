$NomDomaine = Read-Host "Nom du domaine"
$NomMachine = Read-Host "Nom de la machine"
$IPMachine  = Read-Host "IP de la machine"

Write-Host " Configuration DNS " -ForegroundColor Cyan

Install-WindowsFeature -Name DNS -IncludeManagementTools

Add-DnsServerPrimaryZone -Name "$NomDomaine" `
                         -ZoneFile "$NomDomaine.dns" `
                         -ReplicationScope "Forest" `
                         -ErrorAction SilentlyContinue

Add-DnsServerResourceRecordA -ZoneName "$NomDomaine" `
                             -Name "$NomMachine" `
                             -IPv4Address "$IPMachine"

Write-Host "Test Résolution DNS" -ForegroundColor Yellow
Resolve-DnsName -Name "$NomMachine.$NomDomaine"
