$NomDomaine = Read-Host "Confirmez le nom du domaine"
$NomMachine = Read-Host "Nom de la machine à enregistrer"
$IPMachine  = Read-Host "Adresse IP de la machine"

Write-Host "Configuration DNS en cours" -ForegroundColor Cyan

Add-DnsServerPrimaryZone -Name "$NomDomaine" -ZoneFile "$NomDomaine.dns" -ReplicationScope "Forest" -ErrorAction SilentlyContinue

Add-DnsServerResourceRecordA -ZoneName "$NomDomaine" -Name "$NomMachine" -IPv4Address "$IPMachine"

Write-Host "Vérification de l'enregistrement pour $NomMachine.$NomDomaine :" -ForegroundColor Yellow
Resolve-DnsName -Name "$NomMachine.$NomDomaine"
