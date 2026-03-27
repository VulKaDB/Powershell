# --- AVERTISSEMENT --- #
Clear-Host
Write-Host "===============================================================" -ForegroundColor Red
Write-Host "   ATTENTION : AVANT DE COMMENCER" -ForegroundColor Red
Write-Host "   Assurez-vous d'avoir telecharge le fichier 'users.csv'" -ForegroundColor White
Write-Host "   sur votre Machine." -ForegroundColor White
Write-Host "===============================================================" -ForegroundColor Red
Pause

# --- CONFIGURATION DES VARIABLES DE DOMAINE --- #
$Domaine = Read-Host "Entrez le nom du domaine"
$DomainDN = "DC=" + $Domaine.Replace(".", ",DC=")
$OU_Cible = Read-Host "Entrez le nom de l'OU cible"
$CheminOU = "OU=$OU_Cible,$DomainDN"

# --- BOUCLE PRINCIPALE --- #
do {
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host "   GESTION DU DOMAINE : $Domaine" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "1. Ajouter un utilisateur"
    Write-Host "2. Ajouter des utilisateurs via CSV"
    Write-Host "3. Supprimer un utilisateur"
    Write-Host "4. Audit : Comptes désactivés"
    Write-Host "5. Audit : Mots de passe expirés"
    Write-Host "6. Audit : Mots de passe sans expiration"
    Write-Host "7. Audit : Mots de passe faibles (Not Required)"
    Write-Host "Q. Quitter"
    
    $Choix = Read-Host "Votre choix"

    # --- AJOUT MANUEL D'UTILISATEURS --- #
    if ($Choix -eq "1") {
        $Prenom = Read-Host "Prenom"
        $Nom = Read-Host "Nom"
        $Mdp = Read-Host "Mot de passe"
        $SecureMdp = ConvertTo-SecureString $Mdp -AsPlainText -Force
        
        New-ADUser -Name $Prenom -SamAccountName $Nom -UserPrincipalName "$Nom@$Domaine" `
                   -Path $CheminOU -AccountPassword $SecureMdp -Enabled $true
        Write-Host "Utilisateur $Prenom créé !" -ForegroundColor Green
    }

    # --- AJOUT VIA CSV (AVEC VÉRIFICATION) --- #
    elseif ($Choix -eq "2") {
        $Fichier = Read-Host "Chemin complet du fichier CSV (ex: C:\scripts\users.csv)"
        
        # --- Vérification de l'existence du fichier --- #
        if (Test-Path $Fichier) {
            $Import = Import-Csv -Path $Fichier -Delimiter ","
            foreach ($Ligne in $Import) {
                $Pass = ConvertTo-SecureString $Ligne.Password -AsPlainText -Force
                New-ADUser -Name $Ligne.Prenom -SamAccountName $Ligne.Nom `
                           -Path $CheminOU -AccountPassword $Pass -Enabled $true
                Write-Host "Import réussi : $($Ligne.Prenom)" -ForegroundColor Cyan
            }
        } else {
            Write-Host "ERREUR : Le fichier est introuvable : $Fichier" -ForegroundColor Red
            Write-Host "Verifiez que vous l'avez bien telecharge." -ForegroundColor Yellow
        }
    }

    # --- SUPPRESSION D'UN UTILISATEUR --- #
    elseif ($Choix -eq "3") {
        $UserSuppr = Read-Host "Entrez le Nom de famille de l'utilisateur à supprimer"
        
        # Vérification de l'existance de l'utilisateur
        if (Get-ADUser -Filter "SamAccountName -eq '$UserSuppr'") {
            Remove-ADUser -Identity $UserSuppr -Confirm:$false
            Write-Host "L'utilisateur $UserSuppr a été supprimé avec succès." -ForegroundColor Green
        } else {
            Write-Host "ERREUR : L'identifiant '$UserSuppr' n'existe pas dans l'AD." -ForegroundColor Red
        }
    }

    # --- AUDITS --- #
    elseif ($Choix -eq "4") { Get-ADUser -Filter 'Enabled -eq $false' | Select Name, SamAccountName }
    elseif ($Choix -eq "5") { Get-ADUser -Filter 'PasswordExpired -eq $true' | Select Name, SamAccountName }
    elseif ($Choix -eq "6") { Get-ADUser -Filter 'PasswordNeverExpires -eq $true' | Select Name, SamAccountName }
    elseif ($Choix -eq "7") { Get-ADUser -Filter 'PasswordNotRequired -eq $true' | Select Name, SamAccountName }

} while ($Choix -ne "Q")
