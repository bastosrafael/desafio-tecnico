# Guia Local (simples)

Este guia e bem direto, pensado para quem esta fazendo isso pela primeira vez.

## O que voce precisa ter instalado
- Docker
- Git
- kubectl
- Kind (ou Minikube)

## Rodar a aplicacao com Docker

```bash
docker build -t bastosrafael/desafio-devops-app:1.0.0 .
docker run -p 5000:5000 -p 8000:8000 bastosrafael/desafio-devops-app:1.0.0
```

Teste:
- http://localhost:5000/health
- http://localhost:5000/ready
- http://localhost:8000/metrics

## Rodar no Kind

```bash
kind create cluster --name desafio-devops
VERSION=1.0.0 ./scripts/deploy.sh kind
```

Acessar a app:

```bash
kubectl port-forward svc/desafio-devops-app-service 5000:80
```

## Observabilidade

```bash
kubectl port-forward svc/desafio-devops-app-service 8000:8000
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
```

URLs:
- http://localhost:8000/metrics
- http://localhost:9090
- http://localhost:3000 (admin/admin)

Se aparecer aviso de horario no Prometheus, marque "Use local time" na tela.
