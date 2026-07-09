#!/bin/bash
# Ejecutar en CloudShell DESPUES de subir imagenes a ECR.
# Uso: IMAGE_TAG=latest bash scripts/deploy-k8s-cloudshell.sh

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_CLUSTER="${EKS_CLUSTER:-despachos-prod}"
NAMESPACE="${NAMESPACE:-despachos-prod}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Deploy con imagenes: ${ECR_REGISTRY}/*:${IMAGE_TAG}"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER"

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml

for file in k8s/backend-ventas/*.yaml k8s/backend-despachos/*.yaml k8s/frontend/*.yaml k8s/hpa/*.yaml; do
  sed "s|ECR_REGISTRY|${ECR_REGISTRY}|g; s|IMAGE_TAG|${IMAGE_TAG}|g" "$file" | kubectl apply -f -
done

kubectl rollout status deployment/backend-ventas -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/backend-despachos -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment/frontend -n "$NAMESPACE" --timeout=300s

kubectl get pods,svc,hpa -n "$NAMESPACE"
echo ""
kubectl get svc frontend-service -n "$NAMESPACE"
