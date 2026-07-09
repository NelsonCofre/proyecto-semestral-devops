# Proyecto Semestral DevOps — Sistema de Despachos

Monorepo con frontend React, APIs Spring Boot (Ventas y Despachos), despliegue en **Amazon EKS** con CI/CD via **GitHub Actions** y base de datos **Amazon RDS MySQL**.

## Estructura

```
├── frontend/              React + Vite + Nginx
├── backend-ventas/        Spring Boot API (puerto 8080)
├── backend-despachos/     Spring Boot API (puerto 8081)
├── k8s/                   Manifiestos Kubernetes
├── .github/workflows/     Pipelines CI/CD (Fase 9)
└── docker-compose.yml     Orquestación local (IE2)
```

## Ramas Git

| Rama | Uso |
|------|-----|
| `develop` | Desarrollo e integración |
| `deploy` | Dispara pipeline de despliegue a AWS |
| `main` | Código estable en producción |

## Variables de entorno (backends)

| Variable | Descripción |
|----------|-------------|
| `DB_ENDPOINT` | Host RDS MySQL |
| `DB_PORT` | Puerto (3306) |
| `DB_NAME` | Nombre de la BD |
| `DB_USERNAME` | Usuario RDS |
| `DB_PASSWORD` | Contraseña RDS |

## Docker

Cada servicio tiene Dockerfile multietapa y `.dockerignore`.

```bash
# Solo referencia IE2 — la validación principal es en EKS
docker compose up --build
```

- Frontend: http://localhost
- API Ventas: http://localhost:8080/swagger-ui.html
- API Despachos: http://localhost:8081/swagger-ui.html

El frontend usa Nginx como reverse proxy hacia los backends (`/api/v1/ventas`, `/api/v1/despachos`).

## CI/CD (flujo automatico)

El Learner Lab AWS Academy bloquea ECR desde GitHub Actions. El pipeline queda asi:

```
push develop  ->  GitHub Actions (CI: tests + build Docker)
push deploy   ->  GitHub Actions (CI) + CodeBuild webhook (CD: ECR + EKS)
```

### Configuracion inicial CodeBuild (una vez)

1. **CodeBuild** -> **Create build project**
   - Name: `despachos-build`
   - Source: **GitHub** conectado -> repo `proyecto-semestral-devops`, branch `deploy`
   - Webhook: **PUSH**, filtro branch `^deploy$`
   - Environment: Amazon Linux Standard, **Privileged** activado
   - Buildspec: `buildspec.yml`
2. **EKS** -> cluster `despachos-prod` -> **Access** -> agregar rol de servicio de CodeBuild con permisos de cluster admin
3. Secret `db-credentials` en namespace `despachos-prod` (ver `k8s/README.md`)

### Uso diario

```bash
# develop: desarrollo
git push origin develop

# deploy: redeploy automatico en AWS
git checkout deploy && git merge develop && git push origin deploy
```

Respaldo manual si el webhook no dispara: `bash scripts/deploy-cloudshell.sh`

## Kubernetes (EKS)

Ver instrucciones en [`k8s/README.md`](k8s/README.md).

## Stack tecnológico

- **Frontend:** React 18, Vite, Tailwind CSS, Nginx
- **Backend:** Spring Boot 3.4, Java 17, MySQL
- **Infra:** AWS EKS, ECR, RDS, CloudWatch
- **CI/CD:** GitHub Actions

## Autor

Nelson Cofre — Duoc UC · ISY1101 Introducción a Herramientas DevOps
