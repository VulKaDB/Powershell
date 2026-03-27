#!/bin/bash

# --- Effacer l'écran --- #
clear

echo "====================================================="
echo "            SCRIPT AD + CONFIGURATION WEB            "
echo "====================================================="

# --- COLLECTE DES INFORMATIONS --- #
read -p "Entrez le domaine AD à rejoindre (ex: tssr.lan) : " AD_DOMAIN
read -p "Entrez le nom du futur site web (ex: TSSR_WEB) : " WEBSITE_NAME
read -p "Entrez le nom de l'utilisateur : " USERNAME
read -p "Entrez le mot de passe pour cet utilisateur : " USERPASS

echo -e "\n--- 2. INSTALLATION DES DEPENDANCES + JONCTION AD ---\n"

sudo apt update
sudo apt install apache2 realmd sssd sssd-tools adcli samba-common-bin packagekit krb5-user -y

echo "Recherche du domaine $AD_DOMAIN..."
sudo realm discover $AD_DOMAIN
echo "Integration au domaine en cours..."
sudo realm join -U Administrateur $AD_DOMAIN
echo "[OK] Debian est desormais membre du domaine $AD_DOMAIN."

echo -e "\n--- CONFIGURATION DU VIRTUALHOST --- \n"

# --- CRÉATION DE L'UTILISATEUR --- #
if id "$USERNAME" &>/dev/null; then
    echo "[!] L'utilisateur $USERNAME existe deja."
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USERPASS" | sudo chpasswd
    echo "[OK] Utilisateur $USERNAME cree."
fi

# --- CRÉATION DES DOSSIERS --- #
WEBROOT="/var/www/$WEBSITE_NAME/public_html"
sudo mkdir -p "$WEBROOT"
echo "[OK] Dossier racine cree : $WEBROOT"

# --- PERMISSIONS --- #
sudo chown -R "$USERNAME":"$USERNAME" "/var/www/$WEBSITE_NAME"
sudo chmod -R 755 "/var/www/$WEBSITE_NAME"
echo "[OK] Permissions configurees."

# --- PAGE DE TEST --- #
echo "<html><body><h1>Bienvenue sur $WEBSITE_NAME</h1><p>Si vous voyez cette page, c'est gagne !</p></body></html>" | sudo tee "$WEBROOT/index.html" > /dev/null

# --- CRÉATION DU VIRTUALHOST --- #
VHOST_CONF="/etc/apache2/sites-available/$WEBSITE_NAME.conf"

sudo bash -c "cat > $VHOST_CONF" <<EOF
<VirtualHost *:80>
    ServerName $WEBSITE_NAME
    DocumentRoot $WEBROOT
    ErrorLog \${APACHE_LOG_DIR}/error_$WEBSITE_NAME.log
    CustomLog \${APACHE_LOG_DIR}/access_$WEBSITE_NAME.log combined
</VirtualHost>
EOF
echo "[OK] Fichier Virtualhost cree."

# --- ACTIVATION DE LA PAGE WEB --- #
echo "Activation de la nouvelle page web..."

sudo a2dissite 000-default.conf > /dev/null
sudo a2ensite "$WEBSITE_NAME.conf" > /dev/null
sudo systemctl reload apache2

echo -e "\n====================================================="
echo "   PROCESSUS TERMINE AVEC SUCCES !               "
echo "   Machine jointe au domaine : $AD_DOMAIN        "
echo "   Site Web accessible sur : http://$WEBSITE_NAME"
echo -e "\n====================================================="
