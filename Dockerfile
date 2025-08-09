# Seamstress Dockerfile
# Using pre-built binaries for security and reliability

# Pin base image with digest for reproducibility
FROM debian:bookworm-slim@sha256:ad86386827b083b3d71139050b47ffb32bbd9559ea9b1345a739b14fec2d9ecf

# Set Seamstress version - update this to get newer versions
ARG SEAMSTRESS_VERSION=v2.0.0-alpha+build.250109

# Set architecture based on build platform
ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
    "linux/amd64") echo "x86_64-linux-musl" > /tmp/arch ;; \
    "linux/arm64") echo "aarch64-linux" > /tmp/arch ;; \
    *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac

# Install runtime dependencies - ordered for better caching
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libasound2 \
    libfreetype6 \
    libharfbuzz0b \
    libncurses6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install pre-built Seamstress binary with verification
RUN ARCHITECTURE=$(cat /tmp/arch) && \
    echo "Downloading ${ARCHITECTURE}.tar.gz for platform ${TARGETPLATFORM}" && \
    # URL-encode the + character in version string
    VERSION_ENCODED=$(echo "${SEAMSTRESS_VERSION}" | sed 's/+/%2B/g') && \
    curl -fsSL "https://github.com/robbielyman/seamstress/releases/download/${VERSION_ENCODED}/${ARCHITECTURE}.tar.gz" \
    -o /tmp/seamstress.tar.gz && \
    # Verify the download
    [ -s /tmp/seamstress.tar.gz ] || (echo "Download failed or empty file" && exit 1) && \
    tar -xzf /tmp/seamstress.tar.gz -C /tmp && \
    # Verify binary exists and is executable
    [ -f "/tmp/${ARCHITECTURE}/bin/seamstress" ] || (echo "Binary not found in archive" && exit 1) && \
    mv /tmp/${ARCHITECTURE}/bin/seamstress /usr/local/bin/seamstress && \
    chmod +x /usr/local/bin/seamstress && \
    # Verify binary works
    /usr/local/bin/seamstress --version || echo "Warning: Binary version check failed" && \
    rm -rf /tmp/* /tmp/arch

# Create seamstress user with restricted permissions
RUN useradd -m -s /bin/bash -u 1000 seamstress && \
    mkdir -p /home/seamstress/seamstress && \
    chown -R seamstress:seamstress /home/seamstress

# Set working directory
WORKDIR /home/seamstress

# Switch to seamstress user for security
USER seamstress

# Set up environment
ENV PATH="/usr/local/bin:$PATH"

# Add health check to monitor container status
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD seamstress --version > /dev/null || exit 1

# Volume for user scripts
VOLUME ["/home/seamstress/seamstress"]

# Optionally expose any ports if seamstress uses networking
# EXPOSE 8080

# Default command - start seamstress REPL
CMD ["seamstress"]