FROM centos

COPY client-machine-provisioning /tmp/
WORKDIR /tmp/client-machine-setup

RUN yum update -y \
    && yum groupinstall -y "development tools" \
    && yum install -y https://centos7.iuscommunity.org/ius-release.rpm  \
    && yum update -y \
    && yum install -y python36u python36u-libs python36u-devel python36u-pip \
    && ln -s /usr/bin/python3.6 /usr/bin/python3 \
    && ln -s /usr/bin/pip3.6 /usr/bin/pip3 \
    && pip3 install --upgrade pip \
    && yum install -y ansible initscripts openssh-server \
    && ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa \
    && sshd-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys \
    && cat /etc/ssh/ssh_host_rsa_key.pub >> ~/.ssh/known_hosts \
    && echo "StrictHostKeyChecking no" >> ~/.ssh/config \
    && sed -i 's/.*PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/.*#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && ansible-playbook basic-setup.yaml -i hosts/staging --connection=local \
    && rm -rfv /tmp/*.zip /tmp/terraform /tmp/aws_cli /tmp/client-machine-setup \
    && rm -rfv /var/cache/yum \
    && rm -rfv ~/.cache/pip

WORKDIR /tmp
