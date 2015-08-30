# Interpolate templates
interpolatetemplate_inplace "@{product.data}/system/maven/settings.xml"

# Configure Maven
if [ ! -e "@{product.root}/.m2/settings.xml" -a ! -h "@{product.root}/.m2/settings.xml" ]; then
	mkdir -p "@{product.root}/.m2" && chown @{package.user}:@{package.group} "@{product.root}/.m2"
	ln -s "@{product.data}/system/maven/settings.xml" "@{product.root}/.m2/settings.xml" && chown -h @{package.user}:@{package.group} "@{product.root}/.m2/settings.xml"
fi

# Fix data directory permissions
chown -R @{product.user}:@{product.group} "@{package.data}/build"
chmod -R ug=rwX "@{package.data}/build"

# Initialize logs
touch "@{package.log}/repo_update.log" && chown @{product.user}:@{product.group} "@{package.log}/repo_update.log"

# Enable cron job
rm -f "@{product.bin}/cron.5mins/devel-repo-update.sh.lock"
