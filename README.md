## About

This repository provides a Docker base image with a precompiled Pixar USD toolchain, maintained by [Astrum Forge Studios](https://www.astrumforge.com). Built via GitHub Actions, it supports both **arm64** and **amd64** platforms.

## Usage

Use this image as a base for your projects to avoid compiling USD from scratch. The version tag corresponds to the matching USD release from Pixar:

```dockerfile
FROM astrumforge/usd-base:24.11
```

You can also use the `latest` tag to always pull the most recently published version:

```dockerfile
FROM astrumforge/usd-base:latest
```

## Links

- **Pixar USD Repository**: [Pixar USD repository](https://github.com/PixarAnimationStudios/USD) 
- **Docker Repository**: [Docker Hub Repository](https://hub.docker.com/r/astrumforge/usd-base)