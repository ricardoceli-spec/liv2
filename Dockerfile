# -----------------------------
# Etapa 1: Base PHP + Laravel
# -----------------------------
FROM php:8.2-fpm AS base
LABEL fly_launch_runtime="laravel"

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git curl zip unzip sqlite3 libzip-dev vim-tiny \
    && docker-php-ext-install pdo pdo_sqlite mbstring zip xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar Composer desde la imagen oficial de Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Crear directorio de la app
WORKDIR /var/www/html
COPY . .

# Instalar dependencias PHP de Laravel
RUN composer install --no-dev --optimize-autoloader \
    && mkdir -p storage/logs \
    && php artisan optimize:clear \
    && chown -R www-data:www-data /var/www/html

# -----------------------------
# Etapa 2: Build de assets con Node
# -----------------------------
FROM node:18 AS node_build

WORKDIR /app
COPY . .                   # Copia todo el proyecto
COPY --from=base /var/www/html/vendor /app/vendor

# Build de assets (Vite / Mix)
RUN if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then \
        ASSET_CMD="build"; \
    else \
        ASSET_CMD="production"; \
    fi; \
    if [ -f "yarn.lock" ]; then \
        yarn install --frozen-lockfile && yarn $ASSET_CMD; \
    elif [ -f "pnpm-lock.yaml" ]; then \
        corepack enable && corepack prepare pnpm@latest-8 --activate; \
        pnpm install --frozen-lockfile && pnpm run $ASSET_CMD; \
    elif [ -f "package-lock.json" ]; then \
        npm ci --no-audit && npm run $ASSET_CMD; \
    else \
        npm install && npm run $ASSET_CMD; \
    fi

# -----------------------------
# Etapa 3: Imagen final
# -----------------------------
FROM php:8.2-fpm AS final

# Instalar dependencias de sistema necesarias en producción
RUN apt-get update && apt-get install -y \
    sqlite3 nginx supervisor cron zip unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copiar app y vendor
COPY --from=base /var/www/html /var/www/html

# Copiar assets generados
COPY --from=node_build /app/public /var/www/html/public

# Crear volumen persistente para SQLite
RUN mkdir -p /data && touch /data/database.sqlite && chown -R www-data:www-data /data

# Permisos
RUN chown -R www-data:www-data /var/www/html

# Exponer puerto de Fly.io
EXPOSE 8080

# Entrypoint
COPY .fly/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
