FROM msoap/shell2http as demyx_api
FROM quay.io/vektorlab/ctop:0.7.1 as demyx_ctop
FROM alpine

# Build date
ARG DEMYX_BUILD

LABEL sh.demyx.image demyx/demyx
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco
LABEL sh.demyx.registry https://hub.docker.com/u/demyx
LABEL sh.demyx.build $DEMYX_BUILD

# Set default environment variables
ENV DEMYX_BRANCH=stable
ENV DEMYX_HOST=demyx
ENV DEMYX_MODE=production
ENV DEMYX_SSH=2222
ENV DEMYX_BUILD="$DEMYX_BUILD"
ENV TZ=America/Los_Angeles

# Install custom packages
RUN set -ex; \
    apk add --no-cache --update \
    bash \
    bind-tools \
    curl \
    dumb-init \
    git \
    htop \
    jq \
    nano \
    openssh \
    rsync \
    sudo \
    tzdata \
    util-linux \
    zsh

# Copy files
COPY . /etc/demyx
# demyx api
COPY --from=demyx_api /app/shell2http /usr/local/bin
# ctop
COPY --from=demyx_ctop /ctop /usr/local/bin/ctop

# Download latest Docker client binary
RUN set -ex; \
    export DEMYX_DOCKER_BINARY=$(curl -sL https://api.github.com/repos/docker/docker-ce/releases/latest | grep '"name":' | awk -F '[:]' '{print $2}' | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/ //g' | sed -e 's/\r//g'); \
    # Set fixed version as a fallback if curling fails
    if [ -z "$DEMYX_DOCKER_BINARY" ]; then export DEMYX_DOCKER_BINARY=18.09.9; fi; \
    wget https://download.docker.com/linux/static/stable/x86_64/docker-"$DEMYX_DOCKER_BINARY".tgz -qO /tmp/docker-"$DEMYX_DOCKER_BINARY".tgz; \
    tar -xzf /tmp/docker-"$DEMYX_DOCKER_BINARY".tgz -C /tmp; \
    mv /tmp/docker/docker /usr/local/bin; \
    rm -rf /tmp/*

# Create demyx user and configure ssh
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    echo demyx:demyx | chpasswd; \
    mkdir -p /home/demyx; \
    \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    sed -i "s|#Port 22|Port 2222|g" /etc/ssh/sshd_config; \
    sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin no|g" /etc/ssh/sshd_config; \
    sed -i "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|g" /etc/ssh/sshd_config; \
    sed -i "s|#PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config; \
    sed -i "s|#PermitEmptyPasswords no|PermitEmptyPasswords no|g" /etc/ssh/sshd_config; \
    sed -i "s|#PermitUserEnvironment no|PermitUserEnvironment yes|g" /etc/ssh/sshd_config; \
    \
    chown demyx:demyx /etc/ssh

# Install Oh-My-Zsh with ys as the default theme
RUN set -ex; \
    sed -i "s|/home/demyx:/sbin/nologin|/home/demyx:/bin/zsh|g" /etc/passwd; \
    \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /root/.zshrc; \
    sed -i 's|# DISABLE_AUTO_UPDATE="true"|DISABLE_AUTO_UPDATE="true"|g' /root/.zshrc; \
    sed -i 's|# DISABLE_UPDATE_PROMPT=="true"|DISABLE_UPDATE_PROMPT=="true"|g' /root/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /root/.zshrc; \
    \
    su -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" -s /bin/sh demyx; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/demyx/.oh-my-zsh/plugins/zsh-autosuggestions; \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /home/demyx/.zshrc; \
    sed -i 's|# DISABLE_AUTO_UPDATE="true"|DISABLE_AUTO_UPDATE="true"|g' /home/demyx/.zshrc; \
    sed -i 's|# DISABLE_UPDATE_PROMPT="true"|DISABLE_UPDATE_PROMPT="true"|g' /home/demyx/.zshrc; \
    sed -i "s/(git)/(git zsh-autosuggestions)/g" /home/demyx/.zshrc; \
    \
    # Symlink demyx command history with root
    ln -s /home/demyx/.zsh_history /root; \
    \
    # Empty out Alpine Linux's MOTD and use demyx motd
    echo "" > /etc/motd; \
    echo 'demyx motd' >> /root/.zshrc; \
    echo 'demyx motd' >> /home/demyx/.zshrc; \
    \
    # Lockdown zshrc
    mv /home/demyx/.zshrc /etc/demyx; \
    echo "alias /bin/ash=\"echo 'zsh: permission denied: ash'\"" >> /etc/demyx/.zshrc; \
    echo "alias ash=\"echo 'zsh: permission denied: ash'\"" >> /etc/demyx/.zshrc; \
    echo "alias /bin/busybox=\"/bin/busybox \"" >> /etc/demyx/.zshrc; \
    echo "alias busybox=\"busybox \"" >> /etc/demyx/.zshrc; \
    echo "alias wget=\"echo 'zsh: permission denied: wget'\"" >> /etc/demyx/.zshrc; \
    \
    chown root:root /etc/demyx/.zshrc; \
    chown -R root:root /home/demyx/.oh-my-zsh; \
    ln -sf /etc/demyx/.zshrc /home/demyx/.zshrc

# Allow demyx user to execute only one script and allow usage of environment variables
RUN set -ex; \
    echo "demyx ALL=(ALL) NOPASSWD: /etc/demyx/demyx.sh, /etc/demyx/bin/demyx-prod.sh, /etc/demyx/bin/demyx-skel.sh, /usr/sbin/crond" > /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_BUILD"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_BRANCH"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_MODE"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_HOST"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_SSH"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DOCKER_HOST"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="TZ"' >> /etc/sudoers.d/demyx; \
    \
    install -d -m 0755 -o demyx -g demyx /demyx; \
    ln -s /demyx /home/demyx

# Set cron and log
RUN set -ex; \
    echo "* * * * * /usr/local/bin/demyx cron minute" > /etc/crontabs/demyx; \
    echo "0 */6 * * * /usr/local/bin/demyx cron six-hour" >> /etc/crontabs/demyx; \
    echo "0 0 * * * /usr/local/bin/demyx cron daily" >> /etc/crontabs/demyx; \
    echo "0 0 * * 0 /usr/local/bin/demyx cron weekly" >> /etc/crontabs/demyx; \
    \
    install -d -m 0755 -o demyx -g demyx /var/log/demyx; \
    touch /var/log/demyx/demyx.log; \
    chown -R demyx:demyx /var/log/demyx

# Sudo wrappers
RUN set -ex; \
    echo '#!/bin/zsh' >> /usr/local/bin/demyx; \
    echo 'sudo /etc/demyx/demyx.sh "$@"' >> /usr/local/bin/demyx; \
    chmod +x /etc/demyx/demyx.sh; \
    chmod +x /usr/local/bin/demyx; \
    \
    echo '#!/bin/zsh' >> /usr/local/bin/demyx-prod; \
    echo 'sudo /etc/demyx/bin/demyx-prod.sh' >> /usr/local/bin/demyx-prod; \
    chmod +x /etc/demyx/bin/demyx-prod.sh; \
    chmod +x /usr/local/bin/demyx-prod; \
    \
    echo '#!/bin/zsh' >> /usr/local/bin/demyx-skel; \
    echo 'sudo /etc/demyx/bin/demyx-skel.sh' >> /usr/local/bin/demyx-skel; \
    chmod +x /etc/demyx/bin/demyx-skel.sh; \
    chmod +x /usr/local/bin/demyx-skel

# Finalize
RUN set -ex; \
    # Lockdown these binaries
    rm -f /bin/sh; \
    chmod o-x /bin/bash; \
    chmod o-x /usr/bin/curl; \
    chmod o-x /usr/local/bin/docker; \
    chown root:root /usr/local/bin/docker; \
    \
    chmod +x /etc/demyx/bin/demyx-api.sh; \
    ln -s /etc/demyx/bin/demyx-api.sh /usr/local/bin/demyx-api; \
    \
    chmod +x /etc/demyx/bin/demyx-crond.sh; \
    ln -s /etc/demyx/bin/demyx-crond.sh /usr/local/bin/demyx-crond; \
    \
    chmod +x /etc/demyx/bin/demyx-dev.sh; \
    chmod o-x /etc/demyx/bin/demyx-dev.sh; \
    ln -s /etc/demyx/bin/demyx-dev.sh /usr/local/bin/demyx-dev; \
    \
    chmod +x /etc/demyx/bin/demyx-init.sh; \
    ln -s /etc/demyx/bin/demyx-init.sh /usr/local/bin/demyx-init; \
    \
    chmod +x /etc/demyx/bin/demyx-ssh.sh; \
    ln -s /etc/demyx/bin/demyx-ssh.sh /usr/local/bin/demyx-ssh; \
    \
    chmod +x /etc/demyx/bin/demyx-yml.sh; \
    ln -s /etc/demyx/bin/demyx-yml.sh /usr/local/bin/demyx-yml

EXPOSE 2222 8080
WORKDIR /demyx
USER demyx
ENTRYPOINT ["dumb-init", "demyx-init"]
