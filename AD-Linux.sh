#!/bin/bash

# --- Effacer l'écran --- #
clear

echo "====================================================="
echo "            SCRIPT AD + CONFIGURATION WEB            "
echo "====================================================="

# --- COLLECTE DES INFORMATIONS --- #
read "Entrez le domaine à rejoindre : " AD_DOMAIN
read "Entrez le nom du futur site web : " WEBSITE_NAME
read "Entrez le nom de l'utilisateur : " USERNAME
read "Entrez le mot de passe pour cet utilisateur : " USERPASS

echo  "--- INSTALLATION DES DEPENDANCES + JONCTION AD ---"

sudo apt update
sudo apt install realmd sssd sssd-tools adcli samba-common-bin packagekit krb5-user -y

echo "Recherche du domaine $AD_DOMAIN..."
sudo realm discover $AD_DOMAIN
echo "Integration au domaine en cours..."
sudo realm join -U Administrateur $AD_DOMAIN
echo "[OK] Debian est desormais membre du domaine $AD_DOMAIN."

echo "--- CONFIGURATION DU VIRTUALHOST ---"

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
echo "<html><body><h1>Bienvenue sur $WEBSITE_NAME</h1><p>Site genere par script automatique.</p></body></html>" | sudo tee "$WEBROOT/index.html" > /dev/null

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

# --- ACTIVATION ET RELANCE ---
sudo a2ensite "$WEBSITE_NAME.conf" > /dev/null
sudo systemctl reload apache2

echo "====================================================="
echo "   PROCESSUS TERMINE AVEC SUCCES !                   "
echo "   1. Machine jointe au domaine : $AD_DOMAIN         "
echo "   2. Site Web accessible sur : http://$WEBSITE_NAME "
echo "====================================================="
