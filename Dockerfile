# Dockerfile by Marcos Roberto

FROM centos:centos7
LABEL author="marcos.roberto@defensoria.ce.def.br"
ENV AMBIENTE "development"
ENV APPNAME "app1.devel"
ENV ROOT_DOMAIN "defensoria.ce.def.br"
ENV DOMAIN "${APPNAME}.${ROOT_DOMAIN}"
ENV PORT 8080
ENV GIT_REPO "https://usergit:password@github.com/dpgeceti/sistema-gerenciamanto-estagiario.git /${DOMAIN}/code/sge_test"

RUN echo ${DOMAIN}
RUN echo ${GIT_REPO}

# upgrade...
RUN yum upgrade -y
# add EPEL repo

#Acesso SSH
ENV SSH_USER defensoria
ENV SSH_PASS dpgeceti
RUN yum -y update; yum clean all
RUN yum -y install epel-release openssh-server passwd; yum clean all
ADD ./start.sh /start.sh
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' 
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' 
RUN chmod 755 /start.sh
RUN ./start.sh

#Dependencias PYTHON 3.4
RUN yum -y install python-pip python-setuptools; yum clean all
RUN yum -y install python34 python34-devel python-devel python-pip nginx sqlite3 gcc unzip wget git
RUN pip install --upgrade pip setuptools
RUN pip install uwsgi

# add files
RUN mkdir -p /${DOMAIN}/cfg/
ADD requirements.txt /${DOMAIN}/cfg/
ADD nginx.conf /${DOMAIN}/cfg/
ADD django.params /${DOMAIN}/cfg/
ADD django.ini /${DOMAIN}/cfg/

# define mountable dirs
VOLUME ["/var/log/nginx"]

# add user for later usage..
RUN adduser --home=/${DOMAIN}/code -u 1000 djangouser

# setup the configfiles
RUN ln -s /${DOMAIN}/cfg/django.params /etc/nginx/conf.d/
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_orig
RUN ln -s /${DOMAIN}/cfg/nginx.conf /etc/nginx/

# run pip install
RUN pip install -r /${DOMAIN}/cfg/requirements.txt
ADD run.sh /run.sh
ADD setup.sh /setup.sh
RUN chmod 775 /*.sh

RUN /setup.sh
#ENTRYPOINT ["/usr/sbin/sshd", "-D"]
CMD ["/run.sh"]

