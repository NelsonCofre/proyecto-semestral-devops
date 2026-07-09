# Manifiestos Kubernetes — EKS

## Placeholders de imagen

Los Deployments usan `ECR_REGISTRY` e `IMAGE_TAG`. GitHub Actions (Fase 9) los reemplaza antes de aplicar, por ejemplo:

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-ventas:abc1234
```

## Orden de aplicación (CloudShell)

```bash
aws eks update-kubeconfig --region us-east-1 --name despachos-prod

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml

# Secret con credenciales RDS (no commitear valores reales)
kubectl create secret generic db-credentials \
  --namespace despachos-prod \
  --from-literal=DB_ENDPOINT=TU_RDS_ENDPOINT \
  --from-literal=DB_USERNAME=TU_USUARIO \
  --from-literal=DB_PASSWORD=TU_PASSWORD

kubectl apply -f k8s/backend-ventas/
kubectl apply -f k8s/backend-despachos/
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/hpa/
```

## Verificación

```bash
kubectl get pods,svc,hpa -n despachos-prod
kubectl get svc frontend-service -n despachos-prod
```

## Arquitectura de red

| Servicio | Tipo | Puerto |
|----------|------|--------|
| frontend-service | LoadBalancer | 80 |
| backend-ventas-service | ClusterIP | 8080 |
| backend-despachos-service | ClusterIP | 8081 |

El frontend (Nginx) enruta `/api/v1/ventas` y `/api/v1/despachos` hacia los backends internos.
