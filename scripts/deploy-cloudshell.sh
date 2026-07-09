#!/bin/bash
# Respaldo manual: dispara CodeBuild si el webhook no corrio.
# Flujo normal: push a deploy -> webhook CodeBuild -> build + ECR + EKS (automatico).

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
CODEBUILD_PROJECT="${CODEBUILD_PROJECT:-despachos-build}"

echo "=== Disparando CodeBuild ($CODEBUILD_PROJECT) ==="
BUILD_ID=$(aws codebuild start-build \
  --project-name "$CODEBUILD_PROJECT" \
  --query "build.id" --output text)

echo "Build ID: $BUILD_ID"
echo "Sigue el progreso en: CodeBuild -> Build history -> $BUILD_ID"

while true; do
  STATUS=$(aws codebuild batch-get-builds --ids "$BUILD_ID" --query "builds[0].buildStatus" --output text)
  echo "Estado: $STATUS"
  case "$STATUS" in
    SUCCEEDED)
      echo "Deploy completado."
      aws eks update-kubeconfig --region "$AWS_REGION" --name despachos-prod
      kubectl get svc frontend-service -n despachos-prod
      break
      ;;
    FAILED|FAULT|STOPPED|TIMED_OUT)
      echo "CodeBuild fallo. Revisa logs en la consola."
      exit 1
      ;;
    *) sleep 15 ;;
  esac
done
