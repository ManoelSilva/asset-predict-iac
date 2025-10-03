[Leia em inglês](README.md)

# Asset Predict Infrastructure (Terraform)

Esta configuração do Terraform provisiona uma instância AWS EC2 para hospedar e servir os seguintes projetos:
- [asset-data-lake](../asset-data-lake/README.pt-br.md) (Python/Flask)
- [asset-predict-model](../asset-predict-model/README.pt-br.md) (Python/Flask)
- [asset-predict-web](../asset-predict-web/README.pt-br.md) (Angular)

## Pré-requisitos
- AWS CLI configurado com permissões apropriadas
- Terraform >= 1.0.0
- Um EC2 Key Pair existente (para acesso SSH)
- IAM Role nomeada `LabRole` com as permissões necessárias

## Uso

1. **Inicializar o Terraform**
   ```sh
   terraform init
   ```
2. **Aplicar a configuração**
   ```sh
   terraform apply -var="key_name=SEU_NOME_DO_KEY_PAIR"
   ```
   Substitua `SEU_NOME_DO_KEY_PAIR` pelo nome do seu EC2 key pair.

3. **Acessar a instância**
   O IP público e DNS serão exibidos após o apply. SSH usando:
   ```sh
   ssh -i /caminho/para/sua-chave.pem ec2-user@<ip_publico>
   ```

4. **Deploy do asset-data-lake**
   - Copie a pasta do projeto `asset-data-lake` para a instância EC2 (ex: para `~/asset-data-lake`).
   - Copie `deploy_asset_data_lake.sh` para a instância EC2 (ex: para `~/deploy_asset_data_lake.sh`).
   - Execute o script de deploy:
     ```sh
     sudo bash ~/deploy_asset_data_lake.sh
     ```
   - A API Flask será iniciada como um serviço systemd e habilitada na inicialização.

5. **Deploy dos Projetos**
   A instância terá Python, Node.js e Docker instalados. Scripts de deploy específicos para cada projeto serão adicionados para automatizar a configuração de cada projeto.

## Arquivos
- `main.tf`: Configuração EC2, security group e IAM role
- `outputs.tf`: Outputs para acesso à instância (IP público e DNS)
- `user_data.sh`: Inicializa a instância com software necessário (Python 3.12, Node.js, Docker, Git)
- `deploy_asset_data_lake.sh`: Automatiza deploy e configuração do serviço para asset-data-lake
- `deploy_asset_predict_model.sh`: Automatiza deploy e configuração do serviço para asset-predict-model
- `deploy_asset_predict_web.sh`: Automatiza deploy e configuração do serviço para asset-predict-web
- `asset-predict-web-nginx.conf`: Configuração Nginx para servir o frontend Angular

## Variáveis de Ambiente Necessárias

Antes de fazer o deploy dos serviços, você precisa configurar as seguintes variáveis de ambiente:

### Para asset-data-lake e asset-predict-model:
```bash
export MOTHERDUCK_TOKEN="seu_token_motherduck_aqui"
export EC2_HOST="seu_ip_publico_ec2_ou_dominio"
```

## Processo Completo de Deploy

1. **Deploy da Infraestrutura**
   ```bash
   terraform init
   terraform apply -var="key_name=SEU_NOME_DO_KEY_PAIR"
   ```

2. **Deploy do asset-data-lake**
   ```bash
   # Na instância EC2
   sudo MOTHERDUCK_TOKEN=seu_token EC2_HOST=seu_ip bash deploy_asset_data_lake.sh
   ```

3. **Deploy do asset-predict-model**
   ```bash
   # Na instância EC2
   sudo MOTHERDUCK_TOKEN=seu_token EC2_HOST=seu_ip bash deploy_asset_predict_model.sh
   ```

4. **Deploy do asset-predict-web**
   ```bash
   # Na instância EC2
   sudo bash deploy_asset_predict_web.sh
   ```

## Endpoints dos Serviços

Após o deploy, os seguintes serviços estarão disponíveis:

- **Frontend (Angular)**: `http://seu-ip-ec2/` (porta 80)
- **API Data Lake**: `http://seu-ip-ec2:5002/` (API Flask)
- **API Modelo**: `http://seu-ip-ec2:5001/` (API Flask)

## Considerações de Segurança

- O security group permite SSH (22), HTTP (80), HTTPS (443) e portas customizadas (5001, 5002)
- Considere restringir o acesso SSH ao seu range de IP em produção
- A instância usa um IAM role (`LabRole`) para acesso aos serviços AWS
- Todos os serviços rodam como `ec2-user` com permissões apropriadas

## Estimativa de Custos

- **Instância EC2**: t3.large (~$0.0832/hora)
- **Armazenamento**: Volume EBS gp3 8GB (~$0.08/mês)
- **Transferência de Dados**: Mínima para uso típico
- **Custo total estimado**: ~$60-80/mês para operação contínua

## Solução de Problemas

### Problemas Comuns

1. **Serviços não iniciando**
   ```bash
   # Verificar status do serviço
   sudo systemctl status asset-data-lake
   sudo systemctl status asset-predict-model
   
   # Verificar logs
   sudo journalctl -u asset-data-lake -f
   sudo journalctl -u asset-predict-model -f
   ```

2. **Conflitos de porta**
   ```bash
   # Verificar se as portas estão em uso
   sudo netstat -tlnp | grep :5001
   sudo netstat -tlnp | grep :5002
   ```

3. **Problemas de permissão**
   ```bash
   # Corrigir propriedade
   sudo chown -R ec2-user:ec2-user /opt/asset-*
   ```

4. **Variáveis de ambiente não definidas**
   - Certifique-se de que `MOTHERDUCK_TOKEN` e `EC2_HOST` estão exportadas corretamente
   - Verifique os arquivos de serviço em `/etc/systemd/system/` para variáveis de ambiente

---
[Leia em inglês](README.md)
