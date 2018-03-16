docker-django-nginx-uwsgi-centos7
=================================

A dockerfile with few shell scripts to run an empty Django project, combined with Nginx, uWsgi and sqlite3 tools in a Centos 7.x based container.


Usage
-----

To create the image `docker-django-nginx-uwsgi-centos7/django`, execute the following command on the docker-django-nginx-uwsgi-centos7 folder:

        docker build -t docker-django-nginx-uwsgi-centos7/django .
        or
        docker build -t foo:tag .

To run the image and bind to port 8080:

        docker run -d -p 8080:8080 docker-django-nginx-uwsgi-centos7/django
        or
        docker run -d -p 8080:8080 --name=APP_ALIAS IMAGE_NAME 
        docker run -d -p 8080:8080 -p 422:22 --name=APP_ALIAS IMAGE_NAME  

To check the logs of the container run the below command:

        uWSGI logs:
        docker logs <CONTAINER_ID> or ALIAS

        nginx logs:
        docker exec -it APP_ALIAS tail -f /var/log/nginx/error.log
        docker exec -it APP_ALIAS tail -f /var/log/nginx/access.log


To log in the container shell run the below command:

        docker exec -it APP_ALIAS bash


Apagar containers:

        containers parados:
        docker rm @(docker ps -aq)

        todas as imagems:
        docker rmi @(docker images -aq)

Comandos rápidos:

docker build -t centos7-dpge .
docker run -d -p 8080:8080 -p 422:22 --name=app-teste centos7-dpge

docker rm @(docker ps -aq) ; docker rmi @(docker images -aq)
docker ps -a ; docker images
docker stop app-teste ; docker rm app-teste ; docker build -t centos7-dpge . ; docker run -d -p 8080:8080 -p 422:22 --name=app-teste centos7-dpge ; docker ps

docker exec -it app-teste bash