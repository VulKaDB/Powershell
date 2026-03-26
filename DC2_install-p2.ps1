$NomDomaine = Read-Host "Entrez le nom du domaine à rejoindre"

Write-Host "Promotion du DC2..." -ForegroundColor Cyan

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "Veuillez entrer les identifiants de l'administrateur du domaine" -ForegroundColor Yellow
$Credential = Get-Credential
Install-ADDSDomainController `
    -DomainName "$NomDomaine" `
    -Credential $Credential `
    -InstallDns:$true `
    -Force:$true
