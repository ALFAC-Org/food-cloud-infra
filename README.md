# Repositório Terraform para Infraestrutura em Nuvem

Este é um repositório Git que utiliza o Terraform para gerenciar infraestrutura na nuvem. Nele, você encontrará arquivos de configuração do Terraform que definem a infraestrutura como código. No momento, o repositório está focado na Amazon Web Services (AWS), mas você pode adaptá-lo para outras nuvens públicas também.

## Pré-requisitos

Antes de começar, certifique-se de ter os seguintes itens instalados e configurados em seu ambiente:

1. **Terraform**: A ferramenta que permite definir, visualizar e implantar a infraestrutura de nuvem.
2. **AWS CLI**: A interface de linha de comando da AWS.
3. **Credenciais AWS válidas**: Você precisará de uma chave de acesso e uma chave secreta para autenticar com a AWS.

## Como usar

1. **Clone este repositório**:
git clone https://github.com/seu-usuario/nome-do-repositorio.git


2. **Acesse o diretório do repositório**:
cd nome-do-repositorio


3. **Configure as credenciais AWS em seu ambiente**:
aws configure


4. **Inicialize o diretório Terraform**:
terraform init


5. **Visualize as mudanças que serão feitas**:
terraform plan


6. **Provisione a infraestrutura**:
terraform apply


7. **Para destruir a infraestrutura provisionada**:
terraform destroy


## Recursos provisionados

Os seguintes recursos serão criados com os arquivos de configuração Terraform:

- VPC (10.123.0.0/16)
- Sub-rede pública (10.123.1.0/24)
- Internet Gateway
- Tabela de roteamento
- Security Group
- Par de chaves
- Instância EC2

Lembre-se de personalizar os arquivos de configuração de acordo com suas necessidades específicas. E, claro, sinta-se à vontade para adicionar mais recursos conforme sua infraestrutura cresce!

Contribuições são sempre bem-vindas. Se você tiver sugestões ou melhorias para este repositório, envie um pull request. 🚀



8. **Visualize as mudanças que serão feitas**:
terraform plan

