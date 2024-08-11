# play-server
Arquivo para iniciar as configurações de uma nova aplicação em servidor Ubuntu. Ele vai criar e configurar os domínios e pastas da aplicação no front, back e pagina inicial.

# Script de Configuração de Servidor

Este script automatiza a configuração de um servidor com Nginx, MySQL, SSL, e PM2, além de organizar seu projeto em diretórios específicos e fornecer uma página inicial básica.

## Requisitos

- Servidor rodando Ubuntu
- Acesso de root ou sudo
- Domínios configurados e apontando para o IP do servidor

## Instruções de Uso

### 1. Criar o Script

Clone esse código em seu repositório.

### 2. Tornar o Script Executável
No terminal, torne o script executável com o comando:
   
   ```bash
   chmod +x start_server.sh

### 3. Executar o Script
Execute o script com o comando:

  ```bash
  ./start_server.sh


### 4. Responder às Perguntas
Durante a execução do script, você será solicitado a fornecer as seguintes informações:

Domínio principal: O domínio onde o conteúdo HTML será servido.
Domínio do front-end: O domínio onde o aplicativo Next.js será servido.
Domínio do back-end: O domínio onde o servidor Node.js + Express será servido.
Nome do banco de dados: O nome do banco de dados MySQL que será criado.
Nome do usuário MySQL: O nome do usuário MySQL que terá permissões no banco de dados.
Senha do usuário MySQL: A senha do usuário MySQL.
Caminho para o arquivo de entrada do aplicativo: O caminho para o arquivo principal do seu aplicativo (por exemplo, app.js ou server.js).
Nome do processo PM2: O nome que você deseja dar ao processo gerenciado pelo PM2.


### 5. Verificar a Configuração
Após a conclusão do script:

Verifique que o Nginx está servindo os domínios conforme esperado.
Confirme que o SSL está ativo e funcionando.
Teste a conexão ao banco de dados MySQL usando as credenciais fornecidas.
Verifique se o aplicativo está rodando corretamente e sendo gerenciado pelo PM2.


### 6. Estrutura do Projeto
O script criará a seguinte estrutura de diretórios em /var/www/html:

/var/www/html/index.html: Página inicial para o domínio principal.
/var/www/html/front: Diretório para os arquivos do front-end.
/var/www/html/back: Diretório para os arquivos do back-end.

### 7. Manutenção
Atualizações de SSL: O Certbot deve renovar automaticamente os certificados SSL, mas você pode verificar a renovação manualmente com:

bash
Copiar código
sudo certbot renew --dry-run
Gerenciamento de PM2: Você pode gerenciar o processo PM2 com comandos como:

bash
Copiar código
pm2 status      # Verificar status dos processos
pm2 restart <nome_pm2>  # Reiniciar o processo
pm2 stop <nome_pm2>     # Parar o processo

