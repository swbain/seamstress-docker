# Seamstress Dockerfile
# Using pre-built binaries for security and reliability

FROM debian:bookworm-slim

# Set Seamstress version - update this to get newer versions
ARG SEAMSTRESS_VERSION=v2.0.0-alpha.3
ARG ARCHITECTURE=x86_64

# Install runtime dependencies and curl for downloading
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libfreetype6 \
    libharfbuzz0b \
    libncurses6 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Download and install pre-built Seamstress binary
RUN curl -L "https://github.com/robbielyman/seamstress/releases/download/${SEAMSTRESS_VERSION}/seamstress-${SEAMSTRESS_VERSION}-linux-${ARCHITECTURE}.tar.gz" \
    | tar -xz -C /tmp && \
    mv /tmp/seamstress-${SEAMSTRESS_VERSION}-linux-${ARCHITECTURE}/seamstress /usr/local/bin/seamstress && \
    chmod +x /usr/local/bin/seamstress && \
    rm -rf /tmp/seamstress-*

# Create seamstress user
RUN useradd -m -s /bin/bash seamstress

# Create seamstress directory for user scripts
RUN mkdir -p /home/seamstress/seamstress
WORKDIR /home/seamstress

# Change ownership to seamstress user
RUN chown -R seamstress:seamstress /home/seamstress

# Switch to seamstress user
USER seamstress

# Set up environment
ENV PATH="/usr/local/bin:$PATH"

# Default command - start seamstress REPL
CMD ["seamstress"]

# Optionally expose any ports if seamstress uses networking
# EXPOSE 8080

# Volume for user scripts
VOLUME ["/home/seamstress/seamstress"]