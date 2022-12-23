ARG VERSION=1.0.0

FROM --platform=linux/amd64 mambaorg/micromamba:1.1.0
LABEL authors="mriffle@uw.edu" \
      description="Docker image for most of nf-maccoss-trex"

# Install procps so that Nextflow can poll CPU usage and
# deep clean the apt cache to reduce image/layer size
RUN apt-get update \
    && apt-get install -y procps sqlite3 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Setup micromamba:
ARG MAMBA_USER=mamba
ARG MAMBA_USER_ID=1000
ARG MAMBA_USER_GID=1000
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
    /usr/local/bin/_dockerfile_setup_root_prefix.sh

# Setup the environment
USER root
COPY environment.yml /tmp/environment.yml

# Create the environment
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

# Set the path. NextFlow seems to circumvent the conda environment
# We also need to set options for the JRE here.
ENV PATH="$MAMBA_ROOT_PREFIX/bin:$PATH" _JAVA_OPTIONS="-Djava.awt.headless=true" VERSION=$VERSION

# Create the entrypoint:
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
CMD []
