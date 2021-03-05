FROM "bitnami/minideb:buster" as builder
SHELL [ "/bin/bash", "-e", "-u", "-o", "pipefail", "-c" ]

ARG WEBPROC_VERSION="0.4.0"
ARG DNSMASQ_VERSION="2.83"

# Pre-requisite software
RUN install_packages \
	"build-essential" \
	"pkg-config" \
	"libidn11-dev" \
	"nettle-dev" \
	"ca-certificates" \
	"curl"

# Download and extract the webproc
RUN curl --silent --show-error \
	--location \
	"https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz" \
	| gunzip >"/tmp/webproc"
RUN chmod "+x" "/tmp/webproc"

# Download and build Dnsmasq
RUN curl --silent --show-error \
	--location \
	"https://thekelleys.org.uk/dnsmasq/dnsmasq-${DNSMASQ_VERSION}.tar.gz" \
	| tar --gunzip --extract --directory "/tmp"

RUN make \
	--directory "/tmp/dnsmasq-${DNSMASQ_VERSION}" \
	install \
	COPTS="-DHAVE_DNSSEC -DHAVE_IDN"

FROM "bitnami/minideb:buster"
LABEL name="dnsmasq"
LABEL maintainer="Mira 'Mireiawen' Manninen"

# Required libraries
RUN install_packages \
	"libidn11"

# Webproc
COPY --from=builder \
	"/tmp/webproc" \
	"/usr/local/bin/webproc"

# Dnsmasq
COPY --from=builder \
	"/usr/local/sbin/dnsmasq" \
	"/usr/local/sbin/dnsmasq"

# Configure dnsmasq
RUN mkdir "/etc/dnsmasq"
COPY "dnsmasq.conf" "/etc/dnsmasq/dnsmasq.conf"
VOLUME "/etc/dnsmasq"

# Expose the ports
EXPOSE "53/udp"
EXPOSE "53/tcp"
EXPOSE "8080/tcp"

# Copy our entrypoint
COPY "entrypoint.sh" "/docker-entrypoint.sh"
ENTRYPOINT [ "/bin/bash", "/docker-entrypoint.sh" ]
CMD [ "dnsmasq" ]
