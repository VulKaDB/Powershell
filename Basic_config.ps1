do {
    Clear-Host 
    Write-Host "=== MENU PRINCIPAL ===" -ForegroundColor Cyan
    Write-Host "1 - Configurer le Reseau"
    Write-Host "2 - Activer Firewall + RDP"
    Write-Host "Q - Quitter le script"
    
    $choix = Read-Host "Votre choix"
    if ($choix -eq "1") {
        $nom = Read-Host "Nom de la Machine"
        $ip  = Read-Host "Adresse IP"
        $gateway  = Read-Host "Passerelle"
        $dns = Read-Host "DNS"
        New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ip -PrefixLength 24 -DefaultGateway $gateway -ErrorAction SilentlyContinue
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dns
        Rename-Computer -NewName $nom -Force
        
        Write-Host "Configuration terminee." -ForegroundColor Green
        
        $msg = "La configuration est terminée. Voulez-vous redémarrer maintenant ?"
        $titre = "En attente de rédémarrage"
        $boutons = 4 # 4 = bouton Oui et Non
        $icone = 32 # 32 = icône Point d'interrogation
        
        $reponse = (New-Object -ComObject WScript.Shell).Popup($msg, 0, $titre, $boutons + $icone)
        if ($reponse -eq 6) { # 6 correspond au bouton 'Oui'
            Restart-Computer
        }
    }
    if ($choix -eq "2") {
        Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block
        New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
        Set-MpPreference -DisableRealtimeMonitoring $false
        auditpol /set /subcategory:"Logon" /success:enable /failure:enable
        
        Pause
    }
} while ($choix -ne "Q")
