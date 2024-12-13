# Base Docker Image with a Precompiled Pixar USD Toolchain
#
# This Docker image provides a stable foundation that includes a fully precompiled
# Pixar USD toolchain. Separating the USD build from other dependencies drastically
# reduces rebuild times, as USD is complex and updated infrequently. Astrum Forge Studios
# utilizes this base image across various open-source projects.
#
# For more details on the USD toolkit, visit:
# https://github.com/PixarAnimationStudios/USD

FROM python:3.13-slim-bookworm

LABEL MAINTAINER="Astrum Forge Studios (https://www.astrumforge.com)"

# Allow specifying USD version at build-time:
ARG USD_VERSION=24.11
ENV USD_VERSION="${USD_VERSION}"

ENV USD_BUILD_PATH="/usr/usd"
ENV USD_PLUGIN_PATH="/usr/usd/plugin/usd"
ENV USD_BIN_PATH="${USD_BUILD_PATH}/bin"
ENV USD_LIB_PATH="${USD_BUILD_PATH}/lib"
ENV PATH="${PATH}:${USD_BIN_PATH}"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${USD_LIB_PATH}"
ENV PYTHONPATH="${PYTHONPATH}:${USD_LIB_PATH}/python"

WORKDIR /usr

# Install prerequisites for compiling USD
RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	build-essential \
	cmake \
	nasm \
	libxrandr-dev \
	libxcursor-dev \
	libxinerama-dev \
	libxi-dev && \
	rm -rf /var/lib/apt/lists/* && \
	pip3 install -U Jinja2 argparse pillow numpy && \
	git clone --branch "v${USD_VERSION}" --depth 1 https://github.com/PixarAnimationStudios/USD.git usdsrc && \
	python3 usdsrc/build_scripts/build_usd.py --no-examples --no-tutorials --no-imaging --no-usdview ${USD_BUILD_PATH} && \
	rm -rf usdsrc && \
	rm -rf ${USD_BUILD_PATH}/build && \
	rm -rf ${USD_BUILD_PATH}/cmake && \
	rm -rf ${USD_BUILD_PATH}/pxrConfig.cmake && \
	rm -rf ${USD_BUILD_PATH}/share && \
	rm -rf ${USD_BUILD_PATH}/src && \
	apt-get purge -y git \
	build-essential \
	cmake \
	nasm \
	libxrandr-dev \
	libxinerama-dev \
	libxi-dev && \
	apt autoremove -y && \
	apt-get autoclean -y
