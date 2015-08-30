# Generate root password
ensurepassword ROOT_PASSWORD
storevar ROOT_PASSWORD_MD5 `echo -n "$ROOT_PASSWORD" | md5sum | cut -d' ' -f 1`
storevar ROOT_PASSWORD_SHA1 `echo -n "$ROOT_PASSWORD" | sha1sum | cut -d' ' -f 1`

# Generate bot password
ensurepassword BOT_PASSWORD
storevar BOT_PASSWORD_MD5 `echo -n "$BOT_PASSWORD" | md5sum | cut -d' ' -f 1`
storevar BOT_PASSWORD_SHA1 `echo -n "$BOT_PASSWORD" | sha1sum | cut -d' ' -f 1`

# Fix password file and cron directory permissions
chmod 550 "@{package.data}/passwd.sh"
chown @{product.user}:@{product.group} "@{product.bin}/cron.5mins" "@{product.bin}/cron.daily" "@{product.bin}/cron.hourly"
chmod ug=rwX "@{product.bin}/cron.5mins" "@{product.bin}/cron.daily" "@{product.bin}/cron.hourly"

# Configure cron jobs
crontab -u @{package.user} "@{product.app}/system/cron/crontab"

# Configure user profile
PROFILE_FILE="@{product.root}/.bash_profile"
if [ ! -e "$PROFILE_FILE" ] || ! grep -q '~/bin/profile\.d' "$PROFILE_FILE"; then
	cat - <<EOL >> "$PROFILE_FILE"

if [ -d ~/bin/profile.d ]; then
	for i in ~/bin/profile.d/*.sh; do
		if [ -r \$i ]; then
			. \$i
		fi
	done
	unset i
fi
EOL
	chown @{package.user}:@{package.group} "$PROFILE_FILE"
fi
