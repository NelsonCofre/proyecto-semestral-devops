#!/bin/bash
# Verificar en CloudShell si el build EC2 termino.
# Uso: bash scripts/check-ec2-build.sh i-XXXXXXXXX

INSTANCE_ID="${1:-}"
REGION="${AWS_REGION:-us-east-1}"

if [ -z "$INSTANCE_ID" ]; then
  echo "Uso: bash scripts/check-ec2-build.sh i-XXXXXXXXX"
  exit 1
fi

STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region "$REGION" \
  --query "Reservations[0].Instances[0].State.Name" --output text)

echo "Estado EC2: $STATE"

echo "--- Ultimas lineas del log de build (si SSM disponible) ---"
aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["tail -30 /var/log/user-data-build.log"]' \
  --region "$REGION" \
  --query "Command.CommandId" --output text 2>/dev/null || echo "SSM no disponible — revisa EC2 -> Monitor -> Get system log"

echo ""
echo "Verificar ECR:"
aws ecr describe-images --repository-name frontend --region "$REGION" --query "imageDetails[*].imageTags" --output table
