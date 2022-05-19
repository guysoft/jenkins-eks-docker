FROM bitnami/jenkins:2.332.2-debian-10-r26
MAINTAINER Guy Sheffer <guy@shapedo.com>
EXPOSE 8080

USER root
WORKDIR /tmp

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-utils \
    wget \
    python3 \
    python3-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt -qyy clean

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod 755 ./kubectl
RUN mv ./kubectl /usr/local/bin

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator
RUN mv ./aws-iam-authenticator /usr/local/bin

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin/eksctl
RUN chmod 755 /usr/local/bin/eksctl
# Give aws/eks same credentials on user and jenkins, both are needed, see https://rtfm.co.ua/en/aws-eksctl-put-http-169-254-169-254-latest-api-token-net-http-request-canceled-2/
RUN ln -s /var/jenkins_home/.aws /root/.aws

RUN wget https://bootstrap.pypa.io/get-pip.py -O - | python3

USER 1001
WORKDIR /

RUN pip3 install --user botocore
RUN pip3 install --user colorama

USER root
RUN pip3 install awscli

COPY ./get_random_pod /usr/local/bin/get_random_pod
RUN chmod +x /usr/local/bin/get_random_pod

USER 1001
