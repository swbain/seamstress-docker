# Dockerized Seamstress

This repository contains Docker configuration for running [Seamstress](https://github.com/robbielyman/seamstress), an art engine and Lua runtime for creating sequencers, music, games, and visuals.

**This Docker setup uses pre-built binaries for security, reliability, and faster builds.**

## Quick Start

### Build the Docker Image

**Multi-platform build (recommended):**
```bash
# Build for both ARM64 (Apple Silicon) and AMD64 (Intel)
docker buildx build --platform linux/amd64,linux/arm64 -t seamstress --load .
```

**Single platform build:**
```bash
docker build -t seamstress .
```

### Run Seamstress REPL

```bash
docker run -it seamstress
```

### Run a Specific Script

```bash
# Place your script in ./scripts/ directory
docker run -it -v $(pwd)/scripts:/home/seamstress/seamstress seamstress seamstress myscript.lua
```

### Using Docker Compose

```bash
# Start seamstress REPL with volume mounts and GUI/audio support
docker-compose up seamstress

# For development (simpler setup)
docker-compose up seamstress-dev

# Run a specific script
docker-compose run seamstress-script seamstress yourscript.lua
```

## Directory Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── scripts/           # Your Lua scripts go here
│   ├── script.lua
│   └── myscript.lua
└── README.md
```

## Features

- **Pre-built binaries**: Uses official GitHub releases for security and reliability
- **Fast builds**: No compilation step required
- **Minimal runtime image**: Only includes necessary dependencies
- **User isolation**: Runs as non-root user
- **Volume support**: Mount your scripts directory
- **Audio support**: Configured for ALSA audio devices
- **GUI support**: X11 forwarding for visual output
- **Version pinning**: Easy to update to specific Seamstress versions

## Why Pre-built Binaries?

This Dockerfile uses pre-built binaries instead of building from source because:

- **Security**: Official releases are signed and verified by the maintainer
- **Reproducibility**: Same binary every time, regardless of build environment
- **Speed**: Much faster docker builds (seconds vs minutes)
- **Reliability**: No build dependencies or compilation issues
- **Supply Chain**: Reduces attack surface by not including build tools
- **Maintenance**: Less complexity in Dockerfile and fewer moving parts

## Audio Setup

For audio functionality on Linux:

```bash
# Run with audio device access
docker run -it --device /dev/snd -v $(pwd)/scripts:/home/seamstress/seamstress seamstress
```

## GUI/Visual Output

If your Seamstress scripts create visual output:

```bash
# Allow X11 forwarding (Linux)
xhost +local:docker
docker run -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $(pwd)/scripts:/home/seamstress/seamstress \
  seamstress
```

## Development Workflow

1. Create your Lua scripts in the `scripts/` directory
2. Run them with: `docker-compose run seamstress-script seamstress yourscript.lua`
3. Use the REPL for interactive development: `docker-compose run seamstress-dev`
4. For GUI/audio projects: `docker-compose up seamstress`

## Available Services

### `seamstress`
Full-featured service with GUI and audio support. Best for visual/audio projects.

### `seamstress-dev`
Lightweight development service without GUI/audio. Good for script development.

### `seamstress-script`
Service for running specific scripts. Override the command to run your script.

## Customization

### Different Seamstress Version

Update the version by changing the build arg:

```bash
docker build --build-arg SEAMSTRESS_VERSION=v2.0.0-alpha+build.250109 -t seamstress .
```

Or update the ARG in the Dockerfile:

```dockerfile
ARG SEAMSTRESS_VERSION=v2.0.0-alpha+build.250109
```

### Multi-Platform Support

This Docker setup automatically builds for both ARM64 and AMD64 architectures using Docker Buildx:

```bash
# Multi-platform build (works on both Apple Silicon and Intel)
docker buildx build --platform linux/amd64,linux/arm64 -t seamstress --load .

# Push to registry with multi-platform support
docker buildx build --platform linux/amd64,linux/arm64 -t your-registry/seamstress --push .
```

The Dockerfile automatically selects the correct Seamstress binary based on the target platform:
- `linux/arm64` → `aarch64-linux.tar.gz`  
- `linux/amd64` → `x86_64-linux-musl.tar.gz`

### Additional Dependencies

Add system packages to the Dockerfile if your scripts need them:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*
```

## Platform-Specific Setup

### Linux
```bash
# Enable X11 forwarding for GUI
xhost +local:docker
docker-compose up seamstress
```

### macOS
```bash
# Install XQuartz for X11 support
brew install --cask xquartz
# Start XQuartz and enable "Allow connections from network clients"
# Then run with IP instead of localhost
export DISPLAY=host.docker.internal:0
docker-compose up seamstress
```

### Windows (WSL2)
```bash
# Install VcXsrv or similar X11 server
# Set DISPLAY variable
export DISPLAY=host.docker.internal:0
docker-compose up seamstress
```

## Troubleshooting

### Build Issues
- Ensure you have internet connection during build (for downloading binaries)
- Check if the specified version exists in GitHub releases
- Verify architecture matches your target platform

### Binary Download Issues
- Check GitHub releases page for available versions
- Ensure the release has binaries for your architecture
- Try a different version if download fails

### Audio Issues
- Ensure your host system has ALSA/PulseAudio running
- Check device permissions: `ls -la /dev/snd`
- Try running with `--privileged` flag if needed

### GUI Issues
- Ensure X11 forwarding is enabled: `xhost +local:docker`
- Check DISPLAY variable is set correctly
- On macOS/Windows, ensure X11 server is running

### Permission Issues
- The container runs as user `seamstress` (not root)
- Ensure your scripts directory is readable: `chmod -R 755 scripts/`

## Example Scripts

Create a simple test script in `scripts/hello.lua`:

```lua
-- scripts/hello.lua
print("Hello from Seamstress!")
print("Lua version: " .. _VERSION)

-- Simple counter example
for i = 1, 5 do
    print("Count: " .. i)
end
```

Run it with:
```bash
docker-compose run seamstress-script seamstress hello.lua
```

## Contributing

Feel free to submit issues and enhancement requests! This setup aims to make Seamstress easily accessible through Docker while maintaining security and performance best practices.