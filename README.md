# Desafio Tecnico DevOps

Esse foi meu primeiro projeto completo de DevOps. A ideia foi pegar uma aplicacao simples e deixar tudo pronto para rodar com Docker, Kubernetes, CI/CD e observabilidade.

A aplicacao e um pequeno backend em Flask com estes endpoints:
- /health
- /ready
- /metrics (Prometheus)

## O que tem aqui

- app/: codigo da aplicacao
- Dockerfile: imagem Docker (multi-stage, sem root)
- k8s/: manifests do Kubernetes (app, Prometheus, Grafana)
- scripts/deploy.sh: deploy local (Kind ou Minikube)
- .github/workflows/ci-cd.yaml: pipeline CI/CD
- grafana-dashboard.json: dashboard do Grafana
- INCIDENT.md: resposta do incidente simulado
- CHECKLIST.md: checklist do desafio

## Como rodar local (Kind)

```bash
kind create cluster --name desafio-devops
VERSION=1.0.0 ./scripts/deploy.sh kind
```

Acessar a app:

```bash
kubectl port-forward svc/desafio-devops-app-service 5000:80
```

Teste rapido:
- http://localhost:5000/health
- http://localhost:5000/ready

## Observabilidade (Prometheus e Grafana)

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
- JSON: grafana-dashboard.json
- Provisionamento automatico: k8s/grafana-dashboard.yaml

## CI/CD

Pipeline com:
- build
- testes dummy
- SonarCloud (quality gate)
- build/push da imagem no Docker Hub
- deploy automatizado em Kind

Evidencias do pipeline:
- docs/pipeline-logs/github-actions-run.png
- docs/pipeline-logs/sonarcloud-success.png

## Observacoes finais

Esse projeto foi feito com foco em cumprir o desafio e mostrar todo o fluxo funcionando. Se quiser, posso evoluir com testes reais, scan de seguranca e Helm.
