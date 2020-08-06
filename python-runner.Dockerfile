FROM python:3.8-buster

ARG TINI_VERSION=v0.19.0

RUN apt-get update && \
    apt-get install -y curl && \
    curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini


RUN apt-get install -y openssh-server && \
    # Creating /run/sshd instead of /var/run/sshd, because in the Debian
    # image /var/run is a symlink to /run. Creating /var/run/sshd directory
    # as proposed in the Docker documentation linked above just doesn't
    # work.
    mkdir -p /run/sshd

EXPOSE 22

ARG GITLAB_RUNNER_VERSION=v11.10.1

RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner && \
    # Test if the downloaded file was indeed a binary and not, for example,
    # an HTML page representing S3's internal server error message or something
    # like that.
    gitlab-runner --version

RUN apt-get install -y bash ca-certificates git git-lfs \
        python3 \
        python3-pip \
        python3-setuptools && \
    git lfs install --skip-repo && \
    pip3 install --upgrade pip

RUN pip3 --no-cache-dir install --upgrade awscli

RUN rm -rf /var/lib/apt/lists/*


COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]





