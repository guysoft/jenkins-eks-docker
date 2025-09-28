FROM jenkins/jenkins:lts
LABEL maintainer="Guy Sheffer <guy@shapedo.com>"
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
    python3-venv \
  && rm -rf /var/lib/apt/lists/* \
  && apt -qyy clean

# Install uv for fast Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Create virtual environment and set it as default
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
ENV VIRTUAL_ENV="/venv"

# Install Python packages using uv in the virtual environment
RUN uv pip install botocore colorama awscli

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

# Make sure jenkins user has access to the virtual environment
RUN chown -R jenkins:jenkins /venv

USER jenkins
WORKDIR /

# Ensure jenkins user also has access to the virtual environment
ENV PATH="/venv/bin:$PATH"
ENV VIRTUAL_ENV="/venv"

USER root
COPY ./get_random_pod /usr/local/bin/get_random_pod
RUN chmod +x /usr/local/bin/get_random_pod

USER jenkins
