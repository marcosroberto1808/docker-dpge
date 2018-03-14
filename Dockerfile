# Dockerfile by Marcos Roberto

FROM centos:centos7
LABEL author="marcos.roberto@defensoria.ce.def.br"
ENV AMBIENTE="development"
ENV APPNAME="app1"
ENV ROOT_DOMAIN = "defensoria.ce.def.br"
ENV DOMAIN ${AMBIENTE}.${APPNAME}.${ROOT_DOMAIN}
ENV PORT 8080

# upgrade...
RUN yum upgrade -y
# add EPEL repo

RUN yum -y install epel-release && yum clean all
RUN yum -y install python-pip python-setuptools && yum clean all
RUN yum install -y python34 python34-devel python-devel python-pip nginx sqlite3 gcc unzip wget git
RUN pip install --upgrade pip setuptools

# install uwsgi 
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

#EXPOSE 8080
# Since docker 1.3.0 we can use variables "anywhere". See #6054.
EXPOSE ${PORT}

CMD ["/run.sh"]

