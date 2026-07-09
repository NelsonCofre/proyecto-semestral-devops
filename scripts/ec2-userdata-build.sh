#!/bin/bash
# User Data para EC2 Amazon Linux 2023 — build y push a ECR (100% AWS)
# Pegar en "Advanced details -> User data" al lanzar la instancia.

set -euxo pipefail
exec > /var/log/user-data-build.log 2>&1

REGION="us-east-1"
REPO="https://github.com/NelsonCofre/proyecto-semestral-devops.git"
BRANCH="deploy"
IMAGE_TAG="latest"

dnf update -y
dnf install -y docker git
systemctl enable docker
systemctl start docker

ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ECR="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR"

git clone -b "$BRANCH" "$REPO" /opt/app
cd /opt/app

for component in frontend backend-ventas backend-despachos; do
  docker build -t "${ECR}/${component}:${IMAGE_TAG}" "./${component}"
  docker push "${ECR}/${component}:${IMAGE_TAG}"
done

echo "BUILD_OK ${ECR} tag ${IMAGE_TAG}" >> /var/log/user-data-build.log
