FROM alpine:3.19

ARG ARCH
ARG KUBECTL_VERSION=1.29.0
ARG HELM_VERSION=3.8.2
ENV TERRAFORM_VERSION=1.7.5
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache bash &&\
    apk add --no-cache python3 &&\
    apk add --no-cache jq &&\
    apk add --no-cache curl &&\
    apk add --no-cache openssh-client &&\
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi &&\
    rm /usr/lib/python3.11/EXTERNALLY-MANAGED &&\
    python -m ensurepip && rm -r /usr/lib/python*/ensurepip &&\
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi &&\
    pip install --no-cache --upgrade pip setuptools wheel && \
    pip3 install requests && \
    pip3 install awscli --upgrade --user && \
    pip3 install hvac &&\
    echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc && \
    source ~/.bashrc && aws --version

RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

RUN . /envfile && echo $ARCH && \
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/2024-01-04/bin/linux/arm64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

RUN . /envfile && echo $ARCH && \
    curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_${ARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/bin && \
    chmod +x /usr/bin/eksctl

COPY --from=gcr.io/kaniko-project/executor:debug /kaniko/executor /kaniko/executor

ENTRYPOINT [""]