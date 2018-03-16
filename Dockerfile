# Dockerfile by Marcos Roberto

# Variaveis de ambiente
FROM centos:centos7
LABEL author="marcos.roberto@defensoria.ce.def.br"
ENV AMBIENTE "development"
ENV APPNAME "app1.devel"
ENV ROOT_DOMAIN "defensoria.ce.def.br"
ENV DOMAIN "${APPNAME}.${ROOT_DOMAIN}"
ENV PORT 8080
ENV GIT_REPO "https://github.com/<repositorio_git>"
ENV GIT_USERNAME "<usuario_git>"
ENV GIT_PASSWORD "<senha_usuario_git>"

RUN echo ${DOMAIN}
RUN echo ${GIT_REPO}


# upgrade...
RUN yum upgrade -y
# add EPEL repo

# Acesso SSH
ENV SSH_USER defensoria
ENV SSH_PASS dpgeceti
RUN yum -y update; yum clean all
RUN yum -y install epel-release openssh-server passwd; yum clean all
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' 
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' 

# Dependencias PYTHON 3.4
RUN yum -y install python-pip python-setuptools; yum clean all
RUN yum -y install python34 python34-devel python-devel python-pip nginx sqlite3 gcc unzip wget git
RUN pip install --upgrade pip setuptools
RUN pip install uwsgi

# Adicionar arquivos
RUN mkdir -p /${DOMAIN}/cfg/
RUN mkdir -p /${DOMAIN}/logs/
COPY ./arquivos/requirements.txt /${DOMAIN}/cfg/
COPY ./arquivos/nginx.conf /${DOMAIN}/cfg/
COPY ./arquivos/django.params /${DOMAIN}/cfg/
COPY ./arquivos/django.ini /${DOMAIN}/cfg/

# define mountable dirs
VOLUME ["/var/log/nginx"]

# add user for later usage..
RUN adduser --home=/${DOMAIN}/code -u 1000 ${SSH_USER}
COPY ".git-credentials" /${DOMAIN}/code/
RUN chown ${SSH_USER}:${SSH_USER} /${DOMAIN}/code/.git-credentials

# setup the configfiles
RUN ln -s /${DOMAIN}/cfg/django.params /etc/nginx/conf.d/
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_orig
RUN ln -s /${DOMAIN}/cfg/nginx.conf /etc/nginx/

# run pip install
RUN pip install -r /${DOMAIN}/cfg/requirements.txt
COPY run.sh /run.sh
COPY setup.sh /setup.sh
RUN chown ${SSH_USER}:nginx /*.sh
RUN touch /${DOMAIN}/logs/${APPNAME}.access.log
RUN touch /${DOMAIN}/logs/${APPNAME}.error.log
RUN touch /${DOMAIN}/logs/${APPNAME}.uwsgi.log
RUN chown -R ${SSH_USER}:nginx /${DOMAIN}
RUN chmod 775 /*.sh
RUN /setup.sh

## Start all
CMD ["/run.sh"]

