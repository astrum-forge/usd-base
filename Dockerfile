# Minimal Docker Image for Pixar USD Toolchain
#
# Builds Pixar Universal Scene Description (USD) from source with minimal dependencies
# and cleans up build artifacts, creating a lightweight image for 64-bit Linux systems
# suitable for general USD-based applications and extensions.
#
# Repository: https://github.com/PixarAnimationStudios/OpenUSD

FROM astrumforge/bullseye-base:latest

LABEL MAINTAINER="Astrum Forge Studios <https://www.astrumforge.com>"

# Allow specifying USD version at build time
ARG USD_VERSION=25.05
ENV USD_VERSION=${USD_VERSION}

# Set USD installation paths and environment variables
ENV USD_BUILD_PATH=/usr/usd
ENV USD_BIN_PATH=${USD_BUILD_PATH}/bin
ENV USD_LIB_PATH=${USD_BUILD_PATH}/lib
ENV PATH=${PATH}:${USD_BIN_PATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${USD_LIB_PATH}
ENV PYTHONPATH=${PYTHONPATH}:${USD_LIB_PATH}/python
ENV PXR_PLUGINPATH_NAME=${USD_BUILD_PATH}/plugin/usd

WORKDIR /usr/src

# Install runtime dependencies for USD and extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
	libxml2 \
	zlib1g \
	libeigen3-dev && \
	rm -rf /var/lib/apt/lists/*

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	build-essential \
	nasm \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev \
	python3 \
	python3-dev \
	python3-pip && \
	pip3 install --no-cache-dir Jinja2 argparse pillow numpy && \
	# Clone USD repository and build minimal core with Draco
	git clone --branch v${USD_VERSION} --depth 1 \
	https://github.com/PixarAnimationStudios/OpenUSD.git usdsrc && \
	python3 usdsrc/build_scripts/build_usd.py \
	--no-examples \
	--no-tutorials \
	--no-imaging \
	--no-usdview \
	--draco \
	--no-materialx \
	${USD_BUILD_PATH} && \
	# Clean up source and build artifacts, preserving pxrConfig.cmake
	rm -rf usdsrc \
	${USD_BUILD_PATH}/build \
	${USD_BUILD_PATH}/cmake \
	${USD_BUILD_PATH}/share \
	${USD_BUILD_PATH}/src && \
	# Remove build dependencies and Python
	pip3 uninstall -y Jinja2 pillow numpy && \
	apt-get purge -y --auto-remove \
	git \
	build-essential \
	nasm \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev \
	python3 \
	python3-dev \
	python3-pip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr