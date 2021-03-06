#!/bin/bash
set -e

# The directory which packages are copied to.
PACKAGES='/root/packages'

# The file which package details are written to.
PACKAGEDB="${PACKAGES}/packages.yml"

# The directory which contains source files.
SOURCES='/root/sources'

# The directory that the InspIRCd source is unpacked to.
SOURCECODE="/root/inspircd-${INSPIRCD_VERSION}"

# Install the required tools and development packages.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install --assume-yes --no-install-recommends \
	build-essential \
	ca-certificates \
	debhelper \
	debhelper-compat \
	wget \
	${DISTRO_PACKAGES}

# Download and unpack the InspIRCd source code.
wget "https://github.com/${INSPIRCD_REPOSITORY}/archive/v${INSPIRCD_VERSION}.tar.gz"
tar fx "v${INSPIRCD_VERSION}.tar.gz"

# Set up and build the package.
mv "${SOURCES}/debian" ${SOURCECODE}
cd ${SOURCECODE}
dpkg-buildpackage

# Copy the packages to the output directory.
echo "${DISTRO_NAME}:" >> ${PACKAGEDB}
for PACKAGE in $(find /root -maxdepth 1 -name '*.deb' -or -name '*.ddeb')
do
	chown "${BUILD_USER}:${BUILD_GROUP}" ${PACKAGE}
	mv ${PACKAGE} ${PACKAGES}
	echo "  - $(basename ${PACKAGE})" >> ${PACKAGEDB}
done
chown "${BUILD_USER}:${BUILD_GROUP}" ${PACKAGEDB}
