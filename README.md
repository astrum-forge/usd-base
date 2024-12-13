## About

This repository provides a Docker base image with a precompiled Pixar USD toolchain, maintained by [Astrum Forge Studios](https://www.astrumforge.com). Built via GitHub Actions, it supports both **arm64** and **amd64** platforms.

## Usage

Use this image as a base for your projects to avoid compiling USD from scratch. The version tag corresponds to the matching USD release from Pixar:

```dockerfile
FROM astrumforge/usd-base:v-24.11
```

For more details, visit the [Docker Hub Repository](https://hub.docker.com/r/astrumforge/usd-base).

For additional information on Pixar USD, check out the [Pixar USD repository](https://github.com/PixarAnimationStudios/USD).