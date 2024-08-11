#!/bin/bash

# Função para perguntar ao usuário
ask() {
    read -p "$1: " value
    echo $value
}

# Perguntas ao usuário
DOMINIO_PRINCIPAL=$(ask "Digite o domínio principal")
DOMINIO_FRONT=$(ask "Digite o domínio do front-end")
DOMINIO_BACK=$(ask "Digite o domínio do back-end")
NOME_BANCO=$(ask "Digite o nome do banco de dados")
USUARIO_MYSQL=$(ask "Digite o nome do usuário MySQL")
SENHA_MYSQL=$(ask "Digite a senha do usuário MySQL")
CAMINHO_APP=$(ask "Digite o caminho para o arquivo de entrada do aplicativo")
NOME_PM2=$(ask "Digite o nome do processo PM2")

# Atualizar e instalar dependências
sudo apt update
sudo apt install -y nginx mysql-server certbot python3-certbot-nginx

# Criar pastas para o front-end e back-end
sudo mkdir -p /var/www/html/front
sudo mkdir -p /var/www/html/back

# Criar arquivo index.html na pasta principal
sudo mkdir -p /var/www/html
sudo bash -c "echo '<html><head><title>Bem-vindo ao ${DOMINIO_PRINCIPAL}</title></head><body><h1>Site em construção</h1><p>Este é o domínio principal: ${DOMINIO_PRINCIPAL}</p></body></html>' > /var/www/html/index.html"

# Configurar Nginx
sudo bash -c "cat > /etc/nginx/sites-available/${DOMINIO_PRINCIPAL} <<EOF
server {
    listen 80;
    server_name ${DOMINIO_PRINCIPAL};

    location / {
        root /var/www/html;
        index index.html;
    }
}

server {
    listen 80;
    server_name ${DOMINIO_FRONT};

    location / {
        root /var/www/html/front;
        try_files \$uri /index.html;
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name ${DOMINIO_BACK};

    location / {
        root /var/www/html/back;
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name database.${DOMINIO_PRINCIPAL};

    location / {
        proxy_pass http://localhost:3306;
    }
}
EOF"

# Habilitar site no Nginx
sudo ln -s /etc/nginx/sites-available/${DOMINIO_PRINCIPAL} /etc/nginx/sites-enabled/
sudo systemctl reload nginx

# Configurar SSL com Certbot
sudo certbot --nginx -d ${DOMINIO_PRINCIPAL} -d www.${DOMINIO_PRINCIPAL}
sudo certbot --nginx -d ${DOMINIO_FRONT}
sudo certbot --nginx -d ${DOMINIO_BACK}

# Configurar MySQL
sudo mysql -u root -p <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
CREATE DATABASE ${NOME_BANCO};
CREATE USER '${USUARIO_MYSQL}'@'%' IDENTIFIED BY '${SENHA_MYSQL}';
GRANT ALL PRIVILEGES ON ${NOME_BANCO}.* TO '${USUARIO_MYSQL}'@'%';
FLUSH PRIVILEGES;
EOF

# Configurar MySQL para escutar em todas as interfaces
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# Abrir a porta 3306 no firewall
sudo ufw allow 3306/tcp

# Iniciar o aplicativo com PM2 e nomear
pm2 start ${CAMINHO_APP} --name ${NOME_PM2}
pm2 save

echo "Configuração concluída com sucesso!"
