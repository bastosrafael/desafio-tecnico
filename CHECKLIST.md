# Checklist do Desafio DevOps

## Parte 1 – Containerizacao (Obrigatoria)
- [x] Dockerfile criado: `Dockerfile`
- [x] Multi-stage build: `Dockerfile`
- [x] Nao roda como root: `Dockerfile` (usuario `appuser`)
- [x] Imagem leve/segura: base `python:3.9-slim-buster` + multi-stage
- [x] Versionamento semantico: tags `v1.0.0` e `1.0.<run_number>`
- [x] Explicacao no README: `README.md`

## Parte 2 – CI/CD (Obrigatoria)
- [x] Pipeline GitHub Actions: `.github/workflows/ci-cd.yaml`
- [x] Build da aplicacao
- [x] Testes automatizados (dummy)
- [x] Analise de codigo SonarCloud real
- [x] Build da imagem Docker
- [x] Publicacao da imagem no Docker Hub
- [x] Deploy automatizado em Kind (no runner)
- [x] Evidencias do pipeline: `docs/pipeline-logs/`

## Parte 3 – Kubernetes / OpenShift (Obrigatoria)
- [x] Deployment: `k8s/deployment.yaml`
- [x] Service: `k8s/service.yaml`
- [x] Readiness Probe configurada
- [x] Liveness Probe configurada
- [x] Requests e limits
- [x] Deploy funcional em Kind (documentado)

## Parte 4 – Observabilidade (Obrigatoria)
- [x] Endpoint `/metrics` exposto na app: `app/main.py`
- [x] Prometheus configurado: `k8s/prometheus-*.yaml`
- [x] Scrape configurado para a app
- [x] Metricas minimas: requests/latencia/status
- [x] Grafana com dashboard
- [x] JSON do dashboard no repo: `grafana-dashboard.json`

## Parte 5 – Automacao (Obrigatoria)
- [x] Script Bash: `scripts/deploy.sh`
- [x] Automatiza deploy local (Kind/Minikube)
- [x] Documentacao no README

## Parte 6 – Incidente Simulado (Obrigatoria)
- [x] Resposta em `INCIDENT.md`

## Extras (Desejavel)
- [x] Dashboard no Grafana
- [ ] Helm Chart
- [ ] Terraform
- [ ] Blue/Green ou Canary
- [ ] Feature flags
- [ ] Scan de imagem/seguranca extra
- [ ] Testes e2e

## Evidencias
- GitHub Actions: `docs/pipeline-logs/github-actions-run.png`
- SonarCloud: `docs/pipeline-logs/sonarcloud-success.png`

