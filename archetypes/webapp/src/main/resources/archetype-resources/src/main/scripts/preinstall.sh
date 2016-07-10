# Disable Nagios monitoring
if type -t nagios_disable_service >/dev/null; then
	nagios_disable_service "${artifactId.substring(0,1).toUpperCase()}${artifactId.substring(1).toLowerCase()}"
fi

# Disable user access to the service
if type -t httpd_disable_service >/dev/null; then
	httpd_disable_service @{project.artifactId}
fi

# Stop the service for safety
stopservice @{package.service}
