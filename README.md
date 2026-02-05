# Desafio TÃ©cnico DevOps

Este repositÃ³rio contÃ©m a soluÃ§Ã£o proposta para o Desafio TÃ©cnico DevOps, abrangendo as Ã¡reas de ContainerizaÃ§Ã£o, CI/CD, Kubernetes, Observabilidade, AutomaÃ§Ã£o e Resposta a Incidentes.

## VisÃ£o Geral do Projeto

O objetivo deste desafio Ã© demonstrar a capacidade de modernizar uma aplicaÃ§Ã£o backend simples, tornando-a containerizada, automatizada e observÃ¡vel. A aplicaÃ§Ã£o de exemplo Ã© um serviÃ§o Flask em Python que expÃµe endpoints de `/health`, `/ready` e `/metrics` (compatÃ­vel com Prometheus).

## Estrutura do RepositÃ³rio

```
 desafio-devops/
 â”œâ”€â”€ app/                  # CÃ³digo-fonte da aplicaÃ§Ã£o backend (Python Flask)
 â”‚   â”œâ”€â”€ main.py           # AplicaÃ§Ã£o Flask com endpoints de saÃºde e mÃ©tricas
 â”‚   â””â”€â”€ requirements.txt  # DependÃªncias Python da aplicaÃ§Ã£o
 â”œâ”€â”€ Dockerfile            # Dockerfile para construir a imagem da aplicaÃ§Ã£o (multi-stage build)
 â”œâ”€â”€ k8s/                  # Manifestos Kubernetes para Deployment e Service
 â”‚   â”œâ”€â”€ deployment.yaml   # Define o Deployment da aplicaÃ§Ã£o no Kubernetes
 â”‚   â””â”€â”€ service.yaml      # Define o Service para expor a aplicaÃ§Ã£o no Kubernetes
 â”œâ”€â”€ .github/              # ConfiguraÃ§Ã£o do GitHub Actions (pipeline CI/CD)
 â”‚   â””â”€â”€ workflows/
 â”‚       â””â”€â”€ ci-cd.yaml    # Pipeline de CI/CD para build, teste e push da imagem Docker
 â”œâ”€â”€ scripts/              # Scripts de automaÃ§Ã£o
 â”‚   â””â”€â”€ deploy.sh         # Script Bash para automatizar o deploy local no Kind/Minikube
 â”œâ”€â”€ INCIDENT.md           # Documento de resposta a um incidente simulado
 â””â”€â”€ README.md             # Este arquivo: VisÃ£o geral e instruÃ§Ãµes do projeto
```

## Como Executar Localmente

Para executar este projeto em seu ambiente local, siga o guia detalhado em `local_execution_guide.md`. Este guia cobre a instalaÃ§Ã£o de prÃ©-requisitos, a execuÃ§Ã£o da aplicaÃ§Ã£o, a containerizaÃ§Ã£o com Docker e a implantaÃ§Ã£o em um cluster Kubernetes local (Kind/Minikube).

## Partes do Desafio Abordadas

### Parte 1 â€“ ContainerizaÃ§Ã£o

-   **Dockerfile**: Utiliza multi-stage build para criar uma imagem leve e segura.
-   **UsuÃ¡rio nÃ£o-root**: A aplicaÃ§Ã£o roda como um usuÃ¡rio nÃ£o-root (`appuser`) dentro do container.
-   **Versionamento**: A imagem Ã© versionada com tags semÃ¢nticas (ex: `bastosrafael/desafio-devops-app:1.0.0`).

### Parte 2 â€“ CI/CD

-   **GitHub Actions**: Implementa um pipeline de CI/CD para automatizar o build, testes (dummy), anÃ¡lise de cÃ³digo (simulada) e push da imagem Docker para um registry pÃºblico.

### Parte 3 â€“ Kubernetes

-   **Manifestos**: `deployment.yaml` e `service.yaml` para implantar a aplicaÃ§Ã£o.
-   **Probes**: ConfiguraÃ§Ã£o de `livenessProbe` e `readinessProbe` para garantir a saÃºde e disponibilidade da aplicaÃ§Ã£o.
-   **Recursos**: DefiniÃ§Ã£o de `requests` e `limits` para CPU e memÃ³ria.

### Parte 4 â€“ Observabilidade

-   **MÃ©tricas**: A aplicaÃ§Ã£o expÃµe mÃ©tricas compatÃ­veis com Prometheus no endpoint `/metrics`.
-   **ConfiguraÃ§Ã£o**: O guia `local_execution_guide.md` demonstra como configurar o Prometheus e Grafana localmente para coletar e visualizar essas mÃ©tricas.

### Parte 5 â€“ AutomaÃ§Ã£o

-   **Script Bash**: Um script `deploy.sh` automatiza o processo de build da imagem Docker, aplicaÃ§Ã£o dos manifestos Kubernetes e verificaÃ§Ã£o do deploy no Kind/Minikube.

### Parte 6 â€“ Incidente Simulado

-   **INCIDENT.md**: ContÃ©m a anÃ¡lise detalhada de um incidente simulado, incluindo investigaÃ§Ã£o, ferramentas, possÃ­veis causas, estratÃ©gia de rollback e prevenÃ§Ã£o.

## ContribuiÃ§Ã£o

Sinta-se Ã  vontade para explorar, testar e sugerir melhorias. Este projeto Ã© um ponto de partida para o desafio DevOps.
## Execucao com Kind

Passos rapidos para subir no Kind:

```bash
kind create cluster --name desafio-devops
VERSION=1.0.0 ./scripts/deploy.sh kind
```

Para acessar a aplicacao:

```bash
kubectl port-forward svc/desafio-devops-app-service 5000:80
```

## Observabilidade (Prometheus/Grafana)

Port-forwards:

```bash
kubectl port-forward svc/desafio-devops-app-service 8000:8000
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
```

URLs:
- Metrics: http://localhost:8000/metrics
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

Dashboard:
- JSON do dashboard: grafana-dashboard.json
- Provisionamento automatico via ConfigMap:
  - k8s/grafana-dashboard.yaml
  - k8s/grafana-dashboard-provisioning.yaml
  - k8s/grafana-deployment.yaml

## CI/CD

O pipeline (GitHub Actions) realiza:
- Build e testes (dummy)
- Analise de codigo (SonarCloud real)
- Build e push da imagem Docker
- Deploy automatizado em cluster Kind no runner

SonarCloud:
- Necessario criar projeto no SonarCloud e configurar os secrets no GitHub:
  - SONAR_TOKEN
  - SONAR_ORG
  - SONAR_PROJECT_KEY
- O scanner usa o arquivo `sonar-project.properties`.

Logs/prints do pipeline:
- Salvar evidencias em `docs/pipeline-logs/`
- Exemplo: `docs/pipeline-logs/github-actions-run.png`

Versionamento:
- Em tags Git (vX.Y.Z), usa a versao X.Y.Z
- Em push normal, usa 1.0.<run_number> e latest
## Evidencias do Pipeline

Coloque aqui os prints/logs do GitHub Actions:
- docs/pipeline-logs/github-actions-run.png
- docs/pipeline-logs/sonarcloud-success.png




