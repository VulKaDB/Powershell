$NomDomaine = Read-Host "Ecrire le nom du domaine"

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature -Name DNS -IncludeManagementTools

Install-ADDSForest -DomainName $NomDomaine `
                   -DomainMode "WinThreshold" `
                   -ForestMode "WinThreshold" `
                   -InstallDns:$true `
                   -Force:$true
