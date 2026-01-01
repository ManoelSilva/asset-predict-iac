[Leia em inglês](DOCKER_SETUP.md)

# Guia de Configuração Docker Compose

Este guia explica como configurar e executar a stack de aplicação Asset Predict localmente usando Docker Compose.

## Visão Geral

O arquivo `docker-compose.yml` orquestra três serviços:
- **asset-predict-model**: Serviço de API do modelo de ML (porta 5001)
- **asset-data-lake**: Serviço de API do data lake (porta 5002)
- **asset-predict-web**: Frontend web Angular servido via nginx (porta 80)

## Pré-requisitos

- Docker e Docker Compose instalados
- Token do MotherDuck para acesso ao banco de dados
- Git (para clonar os projetos de dependência)

## Configuração Inicial

1. **Clone este repositório**:
   ```bash
   git clone <asset-predict-iac-repo-url>
   cd asset-predict-iac
   ```

2. **Clone os projetos de dependência** no mesmo nível deste diretório:
   ```bash
   cd ..
   git clone https://github.com/manoelsilva/asset-predict-model.git asset-predict-model
   git clone https://github.com/manoelsilva/asset-data-lake.git asset-data-lake
   git clone https://github.com/manoelsilva/asset-predict-web.git asset-predict-web
   cd asset-predict-iac
   ```

   A estrutura de diretórios deve ficar assim:
   ```
   projects/
   ├── asset-predict-iac/
   │   └── docker-compose.yml
   ├── asset-predict-model/
   ├── asset-data-lake/
   └── asset-predict-web/
   ```

3. **Crie um arquivo `.env`** no diretório raiz:
   ```bash
   echo "MOTHERDUCK_TOKEN=seu_token_motherduck_aqui" > .env
   ```
   Substitua `seu_token_motherduck_aqui` pelo seu token real do MotherDuck.

4. **Certifique-se de que os arquivos de modelo estão disponíveis**: 
   Certifique-se de que seus arquivos de modelo `.pt` e `.joblib` estão em `../asset-predict-model/src/models/`. Estes serão montados como um volume somente leitura no container.

## Executando os Serviços

### Iniciar todos os serviços:
```bash
docker-compose up -d
```

### Ver logs:
```bash
# Todos os serviços
docker-compose logs -f

# Serviço específico
docker-compose logs -f asset-predict-model
docker-compose logs -f asset-data-lake
docker-compose logs -f asset-predict-web
```

### Parar todos os serviços:
```bash
docker-compose down
```

### Reiniciar um serviço específico:
```bash
docker-compose restart asset-predict-model
```

### Reconstruir serviços após mudanças no código:
```bash
docker-compose up -d --build
```

## Acessando os Serviços

Após iniciar os serviços, você pode acessar:

- **Frontend (Angular)**: `http://localhost`
- **API do Modelo**: `http://localhost:5001`
- **API do Data Lake**: `http://localhost:5002`

O frontend web automaticamente faz proxy das requisições de API:
- `/api/b3/*` → `asset-predict-model:5001`
- `/asset/*` e `/assets` → `asset-data-lake:5002`

## Detalhes dos Serviços

### asset-predict-model
- **Porta**: 5001
- **Verificação de Saúde**: Verificação de conectividade de porta
- **Arquivos de Modelo**: Montados de `../asset-predict-model/src/models` (somente leitura)
- **Variáveis de Ambiente**: 
  - `MOTHERDUCK_TOKEN`: Necessário para acesso ao banco de dados
  - `ASSET_API_BASE_URL`: Automaticamente definido como `http://asset-data-lake:5002/asset/` para comunicação entre serviços Docker

### asset-data-lake
- **Porta**: 5002
- **Verificação de Saúde**: `http://localhost:5002/health`
- **Variáveis de Ambiente**: `MOTHERDUCK_TOKEN`

### asset-predict-web
- **Porta**: 80
- **Verificação de Saúde**: `http://localhost/health`
- **Dependências**: Aguarda asset-predict-model e asset-data-lake estarem prontos

## Rede

Todos os serviços se comunicam através de uma rede bridge Docker (`asset-predict-network`), permitindo que eles se referenciem pelo nome do serviço (ex: `asset-predict-model:5001`).

## Solução de Problemas

### Verificar saúde dos serviços:
```bash
docker-compose ps
```

### Ver logs dos serviços para erros:
```bash
docker-compose logs asset-predict-model
docker-compose logs asset-data-lake
docker-compose logs asset-predict-web
```

### Reiniciar todos os serviços:
```bash
docker-compose restart
```

### Remover todos os containers e redes:
```bash
docker-compose down -v
```

### Verificar se as portas já estão em uso:
```bash
# Windows
netstat -ano | findstr :5001
netstat -ano | findstr :5002
netstat -ano | findstr :80

# Linux/Mac
lsof -i :5001
lsof -i :5002
lsof -i :80
```

## Variáveis de Ambiente

O arquivo `.env` deve conter:
```
MOTHERDUCK_TOKEN=seu_token_motherduck_aqui
```

Este token é automaticamente passado para ambos os serviços Python (asset-predict-model e asset-data-lake).

### Comunicação entre Serviços

O serviço `asset-predict-model` precisa se comunicar com `asset-data-lake` para buscar dados de ativos. No Docker Compose, isso é configurado através da variável de ambiente `ASSET_API_BASE_URL`, que é automaticamente definida como `http://asset-data-lake:5002/asset/` no arquivo docker-compose.yml. Isso permite que os serviços se comuniquem usando nomes de serviços Docker em vez de `localhost`.

**Importante**: Se você estiver executando serviços fora do Docker Compose, pode ser necessário definir `ASSET_API_BASE_URL` manualmente para apontar para a URL correta do serviço asset-data-lake.

## Montagens de Volume

- **Arquivos de modelo**: `../asset-predict-model/src/models` → `/app/src/models` (somente leitura)
  - Isso permite que você atualize arquivos de modelo no host sem reconstruir o container

## Fluxo de Trabalho de Desenvolvimento

1. Faça alterações no código nas pastas dos projetos de dependência
2. Reconstrua o serviço afetado: `docker-compose up -d --build <nome-do-serviço>`
3. Ou reconstrua todos os serviços: `docker-compose up -d --build`
4. Verifique os logs para confirmar as alterações: `docker-compose logs -f <nome-do-serviço>`

## Notas

- Os arquivos de modelo são montados como volumes somente leitura, então você pode atualizá-los sem reconstruir containers
- O arquivo `docker-compose.yml` usa caminhos relativos (`../`) para referenciar os projetos de dependência no mesmo nível do diretório

