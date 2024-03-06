FROM redhat/ubi9
LABEL maintainer="Fabien Zarifian"

ENV container=docker

RUN groupadd -r ansible --gid=980 \
  && useradd -r -g ansible --uid=980 --home-dir=/home/ansible --shell=/bin/bash --create-home ansible \
  && dnf -y update \
  && dnf -y install \
      python3 \
      python3-devel \
      wget \
      gcc \
  && python3 -m ensurepip \
  && python3 -m pip install --upgrade pip setuptools wheel

USER ansible
COPY requirements.txt /home/ansible/requirement.txt
RUN pip3 install --user -r /home/ansible/requirement.txt \
  && rm /home/ansible/requirement.txt
  
USER root
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && mkdir -p /etc/ansible \
  && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts \
  && dnf remove gcc && dnf clean all

ADD https://github.com/fpco/pid1/releases/download/v0.1.3.1/pid1 /usr/bin/pid1
RUN chmod +x /usr/bin/pid1

USER ansible
ENTRYPOINT [ "pid1" ]
