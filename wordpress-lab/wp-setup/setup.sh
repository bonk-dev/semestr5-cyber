#!/bin/sh
set -eu
cd /var/www/html

# entrypoint obrazu wordpress kopiuje pliki i generuje wp-config.php przy pierwszym starcie
until [ -f wp-config.php ]; do
  echo "[wp-setup] czekam na wp-config.php..."
  sleep 2
done

if wp core is-installed 2>/dev/null; then
  echo "[wp-setup] WordPress już zainstalowany, pomijam"
else
  wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email

  wp rewrite structure '/%postname%/' --hard
  wp option update blog_public 0
  wp plugin delete hello akismet || true
fi

echo "[wp-setup] gotowe"
