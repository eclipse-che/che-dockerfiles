ARG FROM_IMAGE
FROM ${FROM_IMAGE}
USER 0
RUN chmod g=u /etc/passwd
COPY [--chown=0:0] entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

USER 10001
WORKDIR /projects
