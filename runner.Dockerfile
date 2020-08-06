FROM docker:18.09

# Install aws-cli
RUN apk -Uuv add groff less python py-pip openssh curl
RUN pip install awscli==1.16.142
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

ARG TINI_VERSION=v0.19.0
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
#RUN chmod +x /usr/local/bin/tini

RUN mkdir -p /run/sshd
EXPOSE 22

ARG GITLAB_RUNNER_VERSION=v11.10.1

RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner && \
    # Test if the downloaded file was indeed a binary and not, for example,
    # an HTML page representing S3's internal server error message or something
    # like that.
    gitlab-runner --version

RUN apk -Uvv add bash ca-certificates git git-lfs tini && \
    git lfs install --skip-repo

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

RUN echo "root:Docker!" | chpasswd

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

