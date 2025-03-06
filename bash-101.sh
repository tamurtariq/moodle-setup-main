#!/bin/bash

# Exit on error
set -e

# Prompt for website domain or IP
read -p "Enter the web address (without http://, e.g., mymoodle123.com or 192.168.1.1): " WEBSITE_ADDRESS

# Update system and install required packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y
sudo apt -y install apache2 php libapache2-mod-php php-mysql graphviz aspell git clamav php-pspell php-curl \
    php-gd php-intl ghostscript php-xml php-xmlrpc php-ldap php-zip php-soap php-mbstring unzip \
    mariadb-server mariadb-client certbot python3-certbot-apache ufw nano

# Clone Moodle repository
echo "Cloning Moodle repository..."
cd /var/www/html
sudo git clone https://github.com/moodle/moodle.git
cd moodle
sudo git checkout origin/MOODLE_405_STABLE
sudo git config pull.ff only

# Set up moodledata directory
echo "Setting up Moodle data directory..."
sudo mkdir -p /var/www/moodledata
sudo chown -R www-data:www-data /var/www/moodledata
sudo find /var/www/moodledata -type d -exec chmod 700 {} \;
sudo find /var/www/moodledata -type f -exec chmod 600 {} \;

# Adjust permissions
echo "Setting up file permissions..."
sudo chmod -R 777 /var/www/html/moodle

# Update PHP configurations
echo "Configuring PHP settings..."
sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini

# Set up Moodle cron job
echo "Configuring cron job..."
echo "* * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" | sudo crontab -u www-data -

# Set up database and user
echo "Setting up MySQL database and user..."
MYSQL_MOODLEUSER_PASSWORD=$(openssl rand -base64 12)
sudo mysql -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY '$MYSQL_MOODLEUSER_PASSWORD';"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON moodle.* TO 'moodleuser'@'localhost';"
echo "Your Moodle user password is: $MYSQL_MOODLEUSER_PASSWORD"

# Configure Moodle database connection
echo "Configuring Moodle database connection..."
cd /var/www/html/moodle
sudo cp config-dist.php config.php
sudo sed -i "s/\$CFG->dbtype    = '.*';/\$CFG->dbtype    = 'mariadb';/" config.php
sudo sed -i "s/\$CFG->dblibrary = '.*';/\$CFG->dblibrary = 'native';/" config.php
sudo sed -i "s/\$CFG->dbhost    = '.*';/\$CFG->dbhost    = 'localhost';/" config.php
sudo sed -i "s/\$CFG->dbname    = '.*';/\$CFG->dbname    = 'moodle';/" config.php
sudo sed -i "s/\$CFG->dbuser    = '.*';/\$CFG->dbuser    = 'moodleuser';/" config.php
sudo sed -i "s/\$CFG->dbpass    = '.*';/\$CFG->dbpass    = '$MYSQL_MOODLEUSER_PASSWORD';/" config.php
sudo sed -i "s/\$CFG->prefix    = '.*';/\$CFG->prefix    = 'mdl_';/" config.php
sudo sed -i "s|\$CFG->wwwroot   = '.*';|\$CFG->wwwroot   = 'http://$WEBSITE_ADDRESS/moodle';|" config.php
sudo sed -i "s|\$CFG->dataroot  = '.*';|\$CFG->dataroot  = '/var/www/moodledata';|" config.php

# Set correct permissions for config.php
echo "Setting correct permissions for config.php..."
sudo chown www-data:www-data /var/www/html/moodle/config.php
sudo chmod 640 /var/www/html/moodle/config.php

# Restart services
echo "Restarting Apache and MySQL..."
sudo systemctl restart apache2 mariadb

echo "Moodle installation completed! Access it at http://$WEBSITE_ADDRESS/moodle"
