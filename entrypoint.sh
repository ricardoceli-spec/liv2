#!/bin/sh
set -e

# 1️⃣ Ejecutar migraciones (SQLite persistente en /data)
echo "Running migrations..."
php artisan migrate --force

# 2️⃣ Limpiar cache y optimizar Laravel
echo "Optimizing Laravel..."
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 3️⃣ Ejecutar scheduler de Laravel en background
echo "Starting Laravel scheduler..."
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1") | crontab -

# 4️⃣ Arrancar PHP-FPM en foreground
echo "Starting PHP-FPM..."
php-fpm -R
