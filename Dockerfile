FROM centos:7
LABEL maintainer="Fabien Zarifian"

ENV container=docker
ENV pip_packages "ansible yamllint ansible-lint flake8 testinfra molecule"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
  (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*; \
  rm -f /lib/systemd/system/anaconda.target.wants/*; \
 && yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      which \
      python-pip \
      python-devel \
      @development \
 && yum clean all

# Install Ansible via Pip.
RUN pip install $pip_packages \
  && sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers \
  && mkdir -p /etc/ansible \
  && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
