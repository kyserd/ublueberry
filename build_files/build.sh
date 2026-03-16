#!/bin/bash

set -ouex pipefail

log() {
	echo "=== $* ==="
}

#######################################################################
# Setup Repositories
#######################################################################

log "Enable Copr repos..."
COPR_REPOS=(
	ulysg/xwayland-satellite
	yalter/niri
)
for repo in "${COPR_REPOS[@]}"; do
	# Try to enable the repo, but don't fail the build if it doesn't support this Fedora version
	if ! dnf5 -y copr enable "$repo" 2>&1; then
		log "Warning: Failed to enable COPR repo $repo (may not support Fedora $RELEASE)"
	fi
done

log "Enable terra repositories..."
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
# Bazzite disabled this for some reason so lets re-enable it again
dnf5 config-manager setopt terra.enabled=1 

#######################################################################
## Install Packages
#######################################################################

# Note that these fedora font packages are preinstalled in the
# bluefin-dx image, along with the SymbolsNerdFont which doesn't
# have an associated fedora package:
#
  # adobe-source-code-pro-fonts
  # google-droid-sans-fonts
  # google-noto-sans-cjk-fonts
  # google-noto-color-emoji-fonts
  # jetbrains-mono-fonts
#
# Because the nerd font symbols are mapped correctly, we can get
# nerd font characters anywhere.
FONTS=(
	fira-code-fonts
	fontawesome-fonts-all
	google-noto-emoji-fonts
)


# Niri and its dependencies from its default config.
# commented out packages are already referenced in this file, OR they
# are prebundled inside our parent image.
NIRI_PKGS=(
	niri
	noctalia-shell
	foot
	fuzzel
)

SDDM_PACKAGES=(
	sddm
	sddm-breeze
	sddm-kcm
	qt6-qt5compat
)

ADDITIONAL_SYSTEM_APPS=(
  fish
)

# we do all package installs in one rpm-ostree command
# so that we create minimal layers in the final image
log "Installing packages using dnf5..."
dnf5 install --setopt=install_weak_deps=False -y \
	"${FONTS[@]}" \
	"${HYPR_DEPS[@]}" \
	"${HYPR_PKGS[@]}" \
	"${NIRI_PKGS[@]}" \
	"${SDDM_PACKAGES[@]}" \
	"${ADDITIONAL_SYSTEM_APPS[@]}"

#######################################################################
### Disable repositeories so they aren't cluttering up the final image
#######################################################################

log "Disable Copr repos to get rid of clutter..."
for repo in "${COPR_REPOS[@]}"; do
	dnf5 -y copr disable "$repo"
done

#######################################################################
### Enable Services
#######################################################################
log "Installing sddm...."
systemctl set-default graphical.target
systemctl enable sddm.service

#######################################################################
### Copy files to /etc
#######################################################################
mkdir -p /etc/niri
cp /ctx/niri-config.kdl /etc/niri/config.kdl

