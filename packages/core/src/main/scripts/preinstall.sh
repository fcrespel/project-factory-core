# Check SELinux mode
if [ -x /usr/sbin/getenforce ]; then
	SELINUX_STATUS=`/usr/sbin/getenforce`
	if [ "$SELINUX_STATUS" = "Enforcing" ]; then
		echo "SELinux is in '$SELINUX_STATUS' mode, which is not supported by this product."
		echo "Please consider disabling it (after reviewing the security implications):"
		echo "- immediately, by executing 'setenforce 0'"
		echo "- at boot, by setting SELINUX=permissive or disabled in /etc/selinux/config"
		exit 1
	fi
fi
