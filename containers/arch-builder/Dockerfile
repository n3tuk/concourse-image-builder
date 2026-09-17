FROM archlinux:base-devel

# As this will be an end-use container, not a pre-built one, we can fully initialise and populate the keyring for Arch
# Linux in order for us to download and verify the core and extra packages from the official Arch Linux repositories.
RUN pacman-key --init && pacman-key --populate archlinux

# To allow our own containers to build using our own repository, we need to add our repository's public key to the
# keyring and sign it into the keyring so that pacman can verify the packages we build and host in our own repository.
COPY containers/arch-builder/assets/repository.pub /tmp
RUN pacman-key --add /tmp/repository.pub && \
    pacman-key --lsign-key "0x$(gpg --with-colons --with-fingerprint /tmp/repository.pub 2>/dev/null | awk -F : '/^pub:/ { print $5 }')" && \
    shred --force --zero /tmp/repository.pub

# Update the Pacman configuration to include our own repository, and then update the system to ensure we have the latest
# packages and security updates before pushing the container for Concourse to retrieve.
COPY containers/arch-builder/assets/pacman.conf /etc/pacman.conf
RUN pacman -Syu --noconfirm
