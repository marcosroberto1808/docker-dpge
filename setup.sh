#!/bin/bash

## SETUP INICIAL
__setup_app() {

if [ -z ${DOMAIN} ]; then
    echo "Error - Nome de domínio vazio!"
    exit 1
fi

# Converter senha com caracteres especiais
GIT_PASS_CONVERT=$(perl -e 'print quotemeta shift(@ARGV)' "${GIT_PASSWORD}")

HOST=`echo ${DOMAIN} | cut -f1 -d '.'`
sed -i "s/DOMAIN/${DOMAIN}/g" /${DOMAIN}/cfg/*
sed -i "s/HOST/${HOST}/g" /${DOMAIN}/cfg/*
sed -i "s/PORT/${PORT}/g" /${DOMAIN}/cfg/*
sed -i "s/APPNAME/${APPNAME}/g" /${DOMAIN}/cfg/*
sed -i "s/SSH_USER/${SSH_USER}/g" /${DOMAIN}/cfg/*
sed -i "s/GIT_USERNAME/${GIT_USERNAME}/g" /${DOMAIN}/code/.git-credentials
sed -i "s/GIT_PASSWORD/${GIT_PASS_CONVERT}/g" /${DOMAIN}/code/.git-credentials

# Configurar local para o uwsgi socket
mkdir /${DOMAIN}/run/
chown ${SSH_USER}:nginx /${DOMAIN}/run/
chmod 775 /${DOMAIN}/run/

echo "O código do projeto está em: /${DOMAIN}/code/${HOST}/" 

# Salvar nome de domínio usado 
echo "${DOMAIN}" > /.django
}

# Clonar repositório do GitHub
__git_clone() {
REPO_PATH=`echo ${DOMAIN} | cut -f1 -d '.'`
echo "Executando git clone do projeto $REPO_PATH" 
su - ${SSH_USER} -c "cd /${DOMAIN}/code/ && git config --global credential.helper store"
su - ${SSH_USER} -c "cd /${DOMAIN}/code/ && git clone ${GIT_REPO} ${REPO_PATH} -b ${GIT_BRANCH}"
mv /${DOMAIN}/cfg/.env /${DOMAIN}/code/${HOST}/
unzip /${DOMAIN}/cfg/static.zip -d /${DOMAIN}/code/${HOST}/app/
chown -R ${SSH_USER}:nginx /${DOMAIN}/code/${HOST}/
chmod +x /${DOMAIN}/code/
}

# Instalar requirementes.txt
__install_requirements() {
HOST=`echo ${DOMAIN} | cut -f1 -d '.'`
echo "Executando a instalacao: pip install requirements.txt" 
source /AppEnv/bin/activate ; pip install -r /${DOMAIN}/code/${HOST}/require*.txt
}

## Chamar Funcoes
__setup_app
__git_clone
__install_requirements