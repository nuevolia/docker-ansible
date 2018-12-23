FROM centos:7
LABEL maintainer="Fabien Zarifian"

ENV container=docker

# Install systemd -- See https://hub.docker.com/_/centos/
RUN mkdir -p /usr/share/info \
 && yum -y update; yum clean all; \
 (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
   rm -f /lib/systemd/system/multi-user.target.wants/*; \
   rm -f /etc/systemd/system/*.wants/*; \
   rm -f /lib/systemd/system/local-fs.target.wants/*; \
   rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
   rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
   rm -f /lib/systemd/system/basic.target.wants/*; \
   rm -f /lib/systemd/system/anaconda.target.wants/*; \
 # yum install 
 yum makecache fast \
 && yum -y install deltarpm epel-release initscripts info \
 && yum -y update \
 && yum -y install \
      sudo \
      which \
      python36 \
      python36-devel \
      @development

ADD requirements.txt /root/requirement.txt
RUN python3.6 -m ensurepip \
  && ln -s /usr/bin/python3.6 /usr/bin/python3 \
  && ln -s /usr/local/bin/pip3 /usr/bin/pip3 \
  && pip3 install --upgrade pip setuptools wheel \
  && pip3 install -r /root/requirement.txt \
  && rm /root/requirement.txt \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && mkdir -p /etc/ansible \
  && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts \
  && yum clean all

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
