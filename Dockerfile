# Base Docker Image with a Precompiled Pixar USD Toolchain
#
# This Docker image demonstrates building Pixar USD from source and cleaning up
# any downloaded source files and build-time dependencies, leaving a minimal image
# containing only the installed USD toolkit.
#
# For more details on the USD toolkit, visit:
# https://github.com/PixarAnimationStudios/USD

FROM astrumforge/bullseye-base:latest

LABEL MAINTAINER="Astrum Forge Studios (https://www.astrumforge.com)"

# Allow specifying USD version at build-time
ARG USD_VERSION=24.11
ENV USD_VERSION="${USD_VERSION}"

# Set environment paths for USD
ENV USD_BUILD_PATH="/usr/usd"
ENV USD_PLUGIN_PATH="/usr/usd/plugin/usd"
ENV USD_BIN_PATH="${USD_BUILD_PATH}/bin"
ENV USD_LIB_PATH="${USD_BUILD_PATH}/lib"
ENV PATH="${PATH}:${USD_BIN_PATH}"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${USD_LIB_PATH}"
ENV PYTHONPATH="${PYTHONPATH}:${USD_LIB_PATH}/python"

WORKDIR /usr

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
	pip3 install --no-cache-dir -U Jinja2 argparse pillow numpy && \
	# Clone the Pixar USD repository and build USD via python3 and pip3-installed dependencies
	git clone --branch "v${USD_VERSION}" --depth 1 https://github.com/PixarAnimationStudios/USD.git usdsrc && \
	python3 usdsrc/build_scripts/build_usd.py --no-examples --no-tutorials --no-imaging --no-usdview --no-draco --no-materialx ${USD_BUILD_PATH} && \
	# Remove source directories and intermediate build files
	rm -rf usdsrc && \
	rm -rf ${USD_BUILD_PATH}/build && \
	rm -rf ${USD_BUILD_PATH}/cmake && \
	rm -rf ${USD_BUILD_PATH}/pxrConfig.cmake && \
	rm -rf ${USD_BUILD_PATH}/share && \
	rm -rf ${USD_BUILD_PATH}/src && \
	# Uninstall Python packages that were only needed for building USD
	pip3 uninstall -y Jinja2 pillow numpy && \
	# Remove build dependencies
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