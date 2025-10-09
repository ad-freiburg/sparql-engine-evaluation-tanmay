# Use an official minimal base image with necessary utilities
FROM i386/debian:stable-slim

# Enable multiarch
RUN dpkg --add-architecture i386

# Update the repository sources and install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Download SP2Bench
RUN wget https://dbis.informatik.uni-freiburg.de/content/projects/SP2B/docs/sp2b-v1_01-full.tar.gz -O /tmp/sp2b-v1_01-full.tar.gz

# Extract SP2Bench
RUN mkdir -p /opt/sp2bench && \
    tar -xzvf /tmp/sp2b-v1_01-full.tar.gz -C /opt/sp2bench && \
    rm /tmp/sp2b-v1_01-full.tar.gz

# Create the output directory
RUN mkdir -p /opt/sp2bench/output

# Set the working directory
WORKDIR /opt/sp2bench/sp2b/bin

# Make the benchmark binary executable
RUN chmod +x sp2b_gen

# Accept UID and GID as build arguments
ARG UID=1000
ARG GID=1000

# Create user and group matching the host
RUN groupadd -g ${GID} sp2b_user && \
    useradd -m -u ${UID} -g ${GID} sp2b_user && \
    chown -R ${UID}:${GID} /opt/sp2bench

# Switch to the non-root user
USER sp2b_user

# Entrypoint script to allow passing in break_condition
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

