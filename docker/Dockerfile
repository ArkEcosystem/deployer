FROM ubuntu:xenial

ARG CONFIG_PATH=docker/config.json
ARG NODE_PORT=4100
ARG EXPLORER_PORT=4200
ARG USER=deployer

ENV USER $USER
ENV TERM linux

ENV DEPLOYER_HOME /home/$USER
ENV CONFIG_PATH $CONFIG_PATH
ENV NODE_PORT $NODE_PORT
ENV EXPLORER_PORT $EXPLORER_PORT
ENV NVM_DIR $DEPLOYER_HOME/.nvm

RUN apt-get update && \
    apt-get install -y jq git curl sudo

RUN useradd -m $USER && echo "$USER:$USER" | chpasswd && adduser $USER sudo && \
    echo "%$USER  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN echo "debconf debconf/frontend select Noninteractive" | sudo debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

USER $USER

COPY . $DEPLOYER_HOME
COPY ./docker/docker-entrypoint.sh /

RUN sudo chmod +x /docker-entrypoint.sh && \
    sudo chown $USER /docker-entrypoint.sh

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash && \
    . $DEPLOYER_HOME/.nvm/nvm.sh && \
    nvm install 8.9.1 && \
    cd $DEPLOYER_HOME && \
    ./bridgechain.sh install-node --config "$CONFIG_PATH" --autoinstall-deps --non-interactive && \
    ./bridgechain.sh install-explorer --config "$CONFIG_PATH" --skip-deps --non-interactive

EXPOSE $NODE_PORT
EXPOSE $EXPLORER_PORT

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["./docker-entrypoint.sh"]
