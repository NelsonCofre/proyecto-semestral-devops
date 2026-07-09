# Ejecutar en tu PC con Docker Desktop y Lab AWS ABIERTO.
# Configura credenciales del lab antes:
#   $env:AWS_ACCESS_KEY_ID="..."
#   $env:AWS_SECRET_ACCESS_KEY="..."
#   $env:AWS_SESSION_TOKEN="..."

$ErrorActionPreference = "Stop"
$Region = "us-east-1"
$ImageTag = "latest"

$Account = aws sts get-caller-identity --query Account --output text
$EcrRegistry = "$Account.dkr.ecr.$Region.amazonaws.com"

Write-Host "Login ECR: $EcrRegistry"
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $EcrRegistry

$components = @("frontend", "backend-ventas", "backend-despachos")

foreach ($name in $components) {
    Write-Host "Building $name..."
    docker build -t "${EcrRegistry}/${name}:${ImageTag}" "./$name"
    Write-Host "Pushing $name..."
    docker push "${EcrRegistry}/${name}:${ImageTag}"
}

Write-Host ""
Write-Host "Imagenes subidas a ECR con tag: $ImageTag"
Write-Host "Siguiente paso en CloudShell:"
Write-Host "  cd ~/proyecto-semestral-devops && git pull origin deploy"
Write-Host "  IMAGE_TAG=$ImageTag bash scripts/deploy-k8s-cloudshell.sh"
