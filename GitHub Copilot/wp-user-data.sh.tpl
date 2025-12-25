#!/bin/bash
yum update -y
amazon-linux-extras enable php8.1
yum clean metadata
yum install -y httpd php php-mbstring php-xml php-mysqlnd wget unzip
systemctl enable httpd
systemctl start httpd

cd /var/www/html
rm -f index.html
wget https://ja.wordpress.org/latest-ja.tar.gz -O /tmp/wp.tar.gz
tar -xzf /tmp/wp.tar.gz -C /tmp
cp -r /tmp/wordpress/* /var/www/html/
chown -R apache:apache /var/www/html

cat > /var/www/html/wp-config.php <<EOF
<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_pass}');
define('DB_HOST', '${db_endpoint}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('AUTH_KEY',         'put-your-unique-phrase-here');
define('SECURE_AUTH_KEY',  'put-your-unique-phrase-here');
define('LOGGED_IN_KEY',    'put-your-unique-phrase-here');
define('NONCE_KEY',       'put-your-unique-phrase-here');
if ( !defined('ABSPATH') ) define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

chown apache:apache /var/www/html/wp-config.php