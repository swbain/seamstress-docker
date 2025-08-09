# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker containerization setup for [Seamstress](https://github.com/robbielyman/seamstress), a Lua runtime and art engine for creating sequencers, music, games, and visuals. The project uses **pre-built binaries** rather than building from source for security, reliability, and faster builds.

## Core Commands

### Docker Operations
```bash
# Multi-platform build (recommended)
docker buildx build --platform linux/amd64,linux/arm64 -t seamstress --load .

# Build with specific version
docker buildx build --platform linux/amd64,linux/arm64 --build-arg SEAMSTRESS_VERSION=v2.0.0-alpha+build.250109 -t seamstress --load .

# Run Seamstress REPL
docker run -it seamstress

# Run with script volume mount
docker run -it -v $(pwd)/scripts:/home/seamstress/seamstress seamstress seamstress myscript.lua
```

### Docker Compose Services
```bash
# Full-featured service with GUI and audio support
docker-compose up seamstress

# Lightweight development service
docker-compose up seamstress-dev

# Run specific scripts
docker-compose run seamstress-script seamstress yourscript.lua
```

## Architecture

### Container Design
- **Base Image**: `debian:bookworm-slim` for minimal footprint
- **Runtime User**: Non-root `seamstress` user for security
- **Binary Source**: Downloads pre-built binaries from GitHub releases
- **Working Directory**: `/home/seamstress` with scripts mounted to `/home/seamstress/seamstress`

### Multi-Service Architecture
The project provides three Docker Compose services for different use cases:

1. **`seamstress`**: Full-featured service with X11 forwarding, audio device access, and host networking
2. **`seamstress-dev`**: Lightweight development service for script development without GUI/audio
3. **`seamstress-script`**: Script execution service with full capabilities

### Key Design Decisions
- **Pre-built binaries**: Uses GitHub releases instead of compilation for security and speed
- **Version pinning**: ARG-based version control for reproducible builds
- **Platform support**: Configurable architecture (x86_64, aarch64)
- **User isolation**: Runs as non-root user with proper permissions

## File Structure
- `Dockerfile`: Multi-stage container definition with runtime dependencies
- `docker-compose.yml`: Three service definitions for different use cases  
- `Readme.md`: Comprehensive documentation and usage examples
- `scripts/`: Directory for user Lua scripts (created at runtime)

## Platform-Specific Considerations

### Linux
- X11 forwarding requires `xhost +local:docker`
- Audio requires `/dev/snd` device access
- Host networking for full GUI/audio integration

### macOS
- Requires XQuartz for X11 support
- Uses `host.docker.internal:0` for DISPLAY
- Audio support limited compared to Linux

### Windows (WSL2)
- Requires X11 server (VcXsrv)
- Similar DISPLAY configuration to macOS

## Version Management
The Seamstress version is controlled via `SEAMSTRESS_VERSION` build argument in the Dockerfile. Current version: `v2.0.0-alpha+build.250109`. Update this to match available releases from the upstream repository.

## Multi-Platform Support
The Dockerfile automatically selects the correct binary based on target platform:
- `linux/arm64` → `aarch64-linux.tar.gz` (Apple Silicon Macs)
- `linux/amd64` → `x86_64-linux-musl.tar.gz` (Intel/AMD servers)

## Security Notes
- Uses pre-built binaries from official GitHub releases
- Runs as non-root user
- Minimal attack surface with slim base image
- No build tools included in final image
- "When writing commit messages, never mention claude code or anthropic"