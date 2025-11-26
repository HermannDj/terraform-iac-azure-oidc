# terraform-iac-azure-oidc

Infrastructure as Code (IaC) project for deploying Azure resources using Terraform with OIDC authentication from GitHub Actions.

## 📋 Prochaines étapes (Next Steps)

### 1. Créer les ressources Azure pour le backend Terraform

Avant de pouvoir utiliser ce projet, vous devez créer les ressources Azure suivantes pour stocker l'état Terraform:

```bash
# Connexion à Azure
az login

# Créer le resource group pour le backend
az group create --name tfstate-backend-rg --location eastus

# Créer le storage account (le nom doit être unique globalement)
az storage account create \
  --name tfstatebackendhermann \
  --resource-group tfstate-backend-rg \
  --sku Standard_LRS \
  --encryption-services blob

# Créer le container pour stocker l'état Terraform
az storage container create \
  --name terraform-tfstate \
  --account-name tfstatebackendhermann
```

### 2. Configurer l'authentification OIDC GitHub ↔ Azure

1. Créer une App Registration dans Azure AD
2. Configurer les Federated Credentials pour GitHub Actions
3. Assigner les rôles nécessaires (Contributor) à l'App Registration

### 3. Configurer les variables GitHub

Dans les paramètres de votre repository GitHub, créez les variables suivantes dans les environnements `test` et `production`:

| Variable | Description |
|----------|-------------|
| `CLIENT_ID` | Azure AD Application Client ID |
| `AZURE_SUBSCRIPTION_ID` | ID de votre subscription Azure |
| `AZURE_TENANT_ID` | ID de votre tenant Azure AD |
| `TF_RESOURCE_GROUP_NAME` | Nom du resource group pour les ressources |
| `TF_ACR_NAME` | Nom du Azure Container Registry |
| `TF_APP_SERVICE_PLAN_NAME` | Nom du App Service Plan |
| `TF_APP_SERVICE_NAME` | Nom du App Service |
| `TF_LOCATION` | Région Azure (ex: "Canada Central") |

### 4. Merger la branche `feat/use-environment`

La branche `feat/use-environment` contient la configuration Terraform complète. Mergez-la dans main:

```bash
git checkout main
git merge feat/use-environment
git push origin main
```

---

## 🖥️ Utilisation locale (Local Development)

### Prérequis

- [Terraform](https://www.terraform.io/downloads) installé (version >= 1.0)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installé
- Un compte Azure avec les permissions nécessaires

### Configuration locale

1. **Cloner le repository:**
   ```bash
   git clone https://github.com/HermannDj/terraform-iac-azure-oidc.git
   cd terraform-iac-azure-oidc
   ```

2. **Se connecter à Azure:**
   ```bash
   az login
   ```

3. **Naviguer vers le dossier Terraform:**
   ```bash
   cd terraform
   ```

4. **Initialiser Terraform:**
   ```bash
   terraform init
   ```

5. **Sélectionner ou créer un workspace:**
   ```bash
   # Pour l'environnement test
   terraform workspace select test || terraform workspace new test
   
   # Ou pour production
   terraform workspace select production || terraform workspace new production
   ```

6. **Valider la configuration:**
   ```bash
   terraform validate
   terraform fmt -check
   ```

7. **Planifier les changements:**
   ```bash
   terraform plan \
     -var="resource_group_name=terraform-iac-rg" \
     -var="acr_name=iacterraformprojectacr" \
     -var="app_service_plan_name=iac-app-service-plan" \
     -var="app_service_name=iacprojectapp" \
     -var="location=Canada Central"
   ```

8. **Appliquer les changements (après review):**
   ```bash
   terraform apply \
     -var="resource_group_name=terraform-iac-rg" \
     -var="acr_name=iacterraformprojectacr" \
     -var="app_service_plan_name=iac-app-service-plan" \
     -var="app_service_name=iacprojectapp" \
     -var="location=Canada Central"
   ```

### Utiliser un fichier de variables (recommandé)

Créez un fichier `terraform.tfvars` (ne pas commiter):

```hcl
resource_group_name   = "terraform-iac-rg"
acr_name              = "iacterraformprojectacr"
app_service_plan_name = "iac-app-service-plan"
app_service_name      = "iacprojectapp"
location              = "Canada Central"
```

Puis exécutez simplement:
```bash
terraform plan
terraform apply
```

---

## 📁 Structure du projet

```
terraform-iac-azure-oidc/
├── .github/
│   └── workflows/
│       └── terraform-pipeline.yml  # GitHub Actions workflow
├── terraform/
│   ├── backend.tf      # Configuration du backend Azure
│   ├── main.tf         # Ressources principales (ACR, App Service)
│   ├── provider.tf     # Configuration du provider Azure
│   ├── variables.tf    # Définition des variables
│   └── outputs.tf      # Outputs Terraform
└── README.md
```

## 🔧 Ressources déployées

- **Azure Container Registry (ACR)** - Pour stocker les images Docker
- **Azure App Service Plan** - Plan d'hébergement Linux B1
- **Azure Linux Web App** - Application web configurée pour Docker

## ⚠️ Résolution des problèmes courants

### Erreur "ResourceGroupNotFound"
Le resource group pour le backend Terraform n'existe pas. Créez-le avec:
```bash
az group create --name tfstate-backend-rg --location eastus
```

### Erreur "State blob is already locked"
L'état Terraform est verrouillé par une opération précédente. Attendez ~10 minutes ou déverrouillez manuellement:
```bash
terraform force-unlock <LOCK_ID>
```

### Erreur d'authentification OIDC
Vérifiez que:
- Les Federated Credentials sont configurées dans Azure AD
- Les variables GitHub sont correctement définies
- L'App Registration a les permissions nécessaires

## 📄 Licence

Ce projet est sous licence MIT.