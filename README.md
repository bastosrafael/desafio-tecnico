# Desafio Técnico DevOps

Este repositório contém a solução proposta para o Desafio Técnico DevOps, abrangendo as áreas de Containerização, CI/CD, Kubernetes, Observabilidade, Automação e Resposta a Incidentes.

## Visão Geral do Projeto

O objetivo deste desafio é demonstrar a capacidade de modernizar uma aplicação backend simples, tornando-a containerizada, automatizada e observável. A aplicação de exemplo é um serviço Flask em Python que expõe endpoints de `/health`, `/ready` e `/metrics` (compatível com Prometheus).

## Estrutura do Repositório

```
 desafio-devops/
 ├── app/                  # Código-fonte da aplicação backend (Python Flask)
 │   ├── main.py           # Aplicação Flask com endpoints de saúde e métricas
 │   └── requirements.txt  # Dependências Python da aplicação
 ├── Dockerfile            # Dockerfile para construir a imagem da aplicação (multi-stage build)
 ├── k8s/                  # Manifestos Kubernetes para Deployment e Service
 │   ├── deployment.yaml   # Define o Deployment da aplicação no Kubernetes
 │   └── service.yaml      # Define o Service para expor a aplicação no Kubernetes
 ├── .github/              # Configuração do GitHub Actions (pipeline CI/CD)
 │   └── workflows/
 │       └── ci-cd.yaml    # Pipeline de CI/CD para build, teste e push da imagem Docker
 ├── scripts/              # Scripts de automação
 │   └── deploy.sh         # Script Bash para automatizar o deploy local no Minikube
 ├── INCIDENT.md           # Documento de resposta a um incidente simulado
 └── README.md             # Este arquivo: Visão geral e instruções do projeto
```

## Como Executar Localmente

Para executar este projeto em seu ambiente local, siga o guia detalhado em `local_execution_guide.md`. Este guia cobre a instalação de pré-requisitos, a execução da aplicação, a containerização com Docker e a implantação em um cluster Kubernetes local (Minikube).

## Partes do Desafio Abordadas

### Parte 1 – Containerização

-   **Dockerfile**: Utiliza multi-stage build para criar uma imagem leve e segura.
-   **Usuário não-root**: A aplicação roda como um usuário não-root (`appuser`) dentro do container.
-   **Versionamento**: A imagem é versionada com tags semânticas (ex: `seu-usuario-docker/desafio-devops-app:1.0.0`).

### Parte 2 – CI/CD

-   **GitHub Actions**: Implementa um pipeline de CI/CD para automatizar o build, testes (dummy), análise de código (simulada) e push da imagem Docker para um registry público.

### Parte 3 – Kubernetes

-   **Manifestos**: `deployment.yaml` e `service.yaml` para implantar a aplicação.
-   **Probes**: Configuração de `livenessProbe` e `readinessProbe` para garantir a saúde e disponibilidade da aplicação.
-   **Recursos**: Definição de `requests` e `limits` para CPU e memória.

### Parte 4 – Observabilidade

-   **Métricas**: A aplicação expõe métricas compatíveis com Prometheus no endpoint `/metrics`.
-   **Configuração**: O guia `local_execution_guide.md` demonstra como configurar o Prometheus e Grafana localmente para coletar e visualizar essas métricas.

### Parte 5 – Automação

-   **Script Bash**: Um script `deploy.sh` automatiza o processo de build da imagem Docker, aplicação dos manifestos Kubernetes e verificação do deploy no Minikube.

### Parte 6 – Incidente Simulado

-   **INCIDENT.md**: Contém a análise detalhada de um incidente simulado, incluindo investigação, ferramentas, possíveis causas, estratégia de rollback e prevenção.

## Contribuição

Sinta-se à vontade para explorar, testar e sugerir melhorias. Este projeto é um ponto de partida para o desafio DevOps.

## Observabilidade (Prometheus/Grafana) - Execucao local

- Metrics OK: http://localhost:8000/metrics (via `kubectl port-forward svc/desafio-devops-app-service 8000:8000`)
- Prometheus UI: http://localhost:9090 (via `kubectl port-forward svc/prometheus 9090:9090`)
- Grafana UI: http://localhost:3000 (via `kubectl port-forward svc/grafana 3000:3000`)

Se o Prometheus abrir com warning de "time drift", sincronize o relogio no WSL:

```bash
sudo hwclock -s
```

Para validar o scrape no Prometheus:

```bash
curl -s http://localhost:9090/api/v1/targets | head -n 80
```

## Observability - Prometheus e Grafana

### Aviso de "time drift" no Prometheus
Esse aviso aparece porque o horario do Prometheus (rodando no WSL/Kubernetes) esta diferente do horario do seu navegador (Windows). Isso nao impede as consultas, mas pode causar resultados estranhos em janelas de tempo curtas.

Como resolver:
- Reabrir o WSL: `wsl --shutdown` no Windows e abrir o WSL de novo.
- Ou ajustar o relogio do WSL: `sudo date -s "$(date -u +"%Y-%m-%d %H:%M:%S")"`.
- Opcional: marcar "Use local time" na UI do Prometheus.

### O que mostram os graficos do dashboard
- Requests per second (all): total de requisicoes por segundo (RPS).
- Requests per second by endpoint/status: RPS separado por endpoint e status HTTP.
- Latency p95: latencia no percentil 95 (95% das requisicoes abaixo desse tempo).
- Latency avg: latencia media das requisicoes.

### Provisionamento automatico do dashboard
O dashboard e provisionado no Grafana via ConfigMap, sem import manual.
Arquivos:
- k8s/grafana-dashboard.yaml
- k8s/grafana-dashboard-provisioning.yaml
- k8s/grafana-deployment.yaml
- grafana-dashboard.json (JSON original para o desafio)
