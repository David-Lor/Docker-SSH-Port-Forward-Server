FROM alpine:latest

ARG USERNAME=ssh

RUN apk --no-cache update && apk --no-cache add openssh-server

RUN addgroup ${USERNAME} && adduser ${USERNAME} -D -G ${USERNAME} --shell=/bin/false && passwd -u ${USERNAME} && \
    mkdir -p /home/${USERNAME}/.ssh && touch /home/${USERNAME}/.ssh/authorized_keys && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh && chmod 600 /home/${USERNAME}/.ssh/authorized_keys

COPY "./sshd_config" "/etc/ssh/sshd_config"
COPY --chown=${USERNAME}:${USERNAME} "./entrypoint.sh" "/entrypoint.sh"

CMD ["sh", "/entrypoint.sh"]
