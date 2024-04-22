#!/bin/bash

phal=https://github.com/laravel/laravel.git
dir_path=/var/www/laravel

#appurl=http://127.0.0.1
#dbconnection=mysql
#dbhost=127.0.0.1
#dbport=3306
#dbdatabase=hello
#dbusername=praise
#dbpassword=hello@721here

sudo apt update -y
sudo apt upgrade -y

sudo add-apt-repository ppa:ondrej/php --yes

sudo apt update -y
sudo apt install php8.2 -y


sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

echo 'check updates'
php -m

sudo apt install apache2 -y

sudo a2enmod rewrite

sudo systemctl restart apache2

sudo apt install ansible 

cd /usr/local/bin

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

sudo mv composer.phar composer


echo 'LAMP status is installed'

cd /var/www

#check directory path

if [ -d $dir_path ]; then
	sudo rm -rf $dir_path

echo 'deleted successfully'

fi

sudo mkdir $dir_path
echo 'cloning laravel repository'

sudo git clone $phal $dir_path 

for i in {1..3}; do
    sudo git clone $phal $dir_path && break || sleep 5
done

if [ ! -f $dir_path/composer.json ]; then
    echo 'Failed to clone Laravel repository'
    exit 1
fi

sudo chown -R $USER:$USER $dir_path
sudo chmod o+w $dir_path
echo 'user permission updated'

cd $dir_path

composer install --optimize-autoloader --no-dev --no-interaction

composer update--no interaction

sudo cp .env.example .env

sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

cd /etc/apache2/sites-available/

apache_user=$(ps aux | grep "apache" | awk '{print $ 1}' | grep -v root | head -n 1)



#sed -i~ '/^APP_URL=/s/=.*/=$appurl/' .env

#sed -i~ '/^DB_CONNECTION=/s/=.*/=$dbconnection/' .env
#sed -i~ '/^DB_HOST=/s/=.*/=$dbhost/' .env
#sed -i~ '/^DB_PORT=/s/=.*/=$dbport/' .env
#sed -i~ '/^DB_DATABASE=/s/=.*/=$dbdatabase/' .env
#sed -i~ '/^DB_USERNAME=/s/=.*/=$dbusername/' .env
#sed -i~ '/^DB_PASSWORD=/s/=.*/=$dbpassword/' .env

sudo touch exam2.conf

echo '<VirtualHost *:80>
    ServerName 192.168.33.10
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
    	Options Indexes FollowSymLinks
	AllowOverride All
	Required all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' |sudo tee /etc/apache2/sites-available/exam2.conf

sudo a2ensite exam2.conf
sudo a2dissite 000-default.conf

sudo systemctl reload apache2
sudo systemctl restart apache2

# Install MySQL Server and Client
sudo apt install mysql-server -y
sudo apt install mysql-client -y

# Start MySQL Service
sudo systemctl start mysql

# Create MySQL Database and User
sudo mysql -uroot -e "CREATE DATABASE Alohan;"
sudo mysql -uroot -e "CREATE USER 'praise'@'localhost' IDENTIFIED BY 'cardoso';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Alohan.* TO 'praise'@'localhost';"

# Navigate to Laravel Directory
cd /var/www/laravel

# Update Laravel .env File
sudo sed -i "s/# DB_CONNECTION=mysql/DB_CONNECTION=mysql/" .env
sudo sed -i "s/# DB_HOST=127.0.0.1/DB_HOST=localhost/" .env
sudo sed -i "s/# DB_PORT=3306/DB_PORT=3306/" .env
sudo sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=Alohan/" .env
sudo sed -i "s/# DB_USERNAME=root/DB_USERNAME=praise/" .env
sudo sed -i "s/# DB_PASSWORD=/DB_PASSWORD=cardoso/" .env

# Generate Laravel Application Key
sudo php artisan key:generate

# Create Storage Link
sudo php artisan storage:link

# Run Database Migrations
sudo php artisan migrate

# Seed Database
sudo php artisan db:seed

# Restart Apache
sudo systemctl restart apache2
