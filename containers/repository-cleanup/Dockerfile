FROM dhi.io/debian-base:trixie-debian13-dev

COPY assets/99-force-confdef /etc/apt/apt.conf.d/99-force-confdef
# hadolint ignore=DL3008 # Do not pin to always ensure we have the latest security updates and patches for the base image
RUN apt-get update && apt-get upgrade --yes && \
		apt-get install --no-install-recommends --assume-yes --verbose-versions awscli-2 && \
		apt-get clean && \
		rm -rf /var/lib/apt/lists/

# Set the SHELL flag with -o pipefail for any RUN commands that contain pipes
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]
