# Base Docker Image with a Precompiled Pixar USD Toolchain
#
# This Docker image provides a stable foundation that includes a fully precompiled
# Pixar USD toolchain. Separating the USD build from other dependencies drastically
# reduces rebuild times, as USD is complex and updated infrequently. Astrum Forge Studios
# utilizes this base image across various open-source projects.
#
# For more details on the USD toolkit, visit:
# https://github.com/PixarAnimationStudios/USD

FROM astrumforge/bullseye-base:3.31.1

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

# Install prerequisites, build USD, and clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	build-essential \
	nasm \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev && \
	pip3 install -U Jinja2 argparse pillow numpy && \
	# Clone the Pixar USD repository and build USD
	git clone --branch "v${USD_VERSION}" --depth 1 https://github.com/PixarAnimationStudios/USD.git usdsrc && \
	python3 usdsrc/build_scripts/build_usd.py --no-examples --no-tutorials --no-imaging --no-usdview ${USD_BUILD_PATH} && \
	# Remove source and build artifacts
	rm -rf usdsrc && \
	rm -rf ${USD_BUILD_PATH}/build && \
	rm -rf ${USD_BUILD_PATH}/cmake && \
	rm -rf ${USD_BUILD_PATH}/pxrConfig.cmake && \
	rm -rf ${USD_BUILD_PATH}/share && \
	rm -rf ${USD_BUILD_PATH}/src && \
	# Remove development tools and dependencies
	apt-get purge -y --auto-remove \
	git \
	build-essential \
	nasm \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*