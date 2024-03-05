FROM redhat/ubi9
LABEL maintainer="Fabien Zarifian"

ENV container=docker

RUN groupadd -r ansible --gid=980exex \
  useradd -r -g ansible --uid=980 --home-dir=/home/ansible --shell=/bin/bash ansible \
  && dnf -y update \
  && dnf -y install \
      sudo \
      python3 \
      python3-devel \
      wget \
      gcc \
  && python3 -m ensurepip \
  && python3 -m pip install --upgrade pip setuptools wheel

COPY requirements.txt /root/requirement.txt
RUN pip3 install -r /root/requirement.txt \
  && rm /root/requirement.txt \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && mkdir -p /etc/ansible \
  && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts \
  && dnf clean all

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 \
  && chmod +x /usr/local/bin/dumb-init

USER ansible
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/bin/bash", "-l" ]
