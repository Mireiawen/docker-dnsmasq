#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ "${1}" == "dnsmasq" ]
then
	set -- \
		webproc \
		--configuration-file "/etc/dnsmasq/dnsmasq.conf" \
		--port "8080" \
		-- dnsmasq --no-daemon --conf-file="/etc/dnsmasq/dnsmasq.conf"
fi

exec "${@}"
