FROM python:3-alpine

ARG USERNAME=ssh

RUN apk --no-cache update && apk --no-cache add openssh-server

RUN addgroup ${USERNAME} && adduser ${USERNAME} -D -G ${USERNAME} --shell=/bin/false && passwd -u ${USERNAME} && \
    mkdir -p /home/${USERNAME}/.ssh && touch /home/${USERNAME}/.ssh/authorized_keys && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh && chmod 600 /home/${USERNAME}/.ssh/authorized_keys

COPY --chown=${USERNAME}:${USERNAME} "./entrypoint.sh" "./setup.py" /

CMD ["sh", "/entrypoint.sh"]

ENV SSH_PORT="2222" \
    SSH_PUBKEYS_LOCATION="/ssh_pubkey" \
    SSH_USER=${USERNAME}
