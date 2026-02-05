#!/bin/bash
set -euo pipefail

MODE="${1:-}"  # kind|minikube|auto
IMAGE_NAME="bastosrafael/desafio-devops-app"
VERSION="${VERSION:-1.0.0}"

if [ -z "$MODE" ] || [ "$MODE" = "auto" ]; then
  if command -v kind >/dev/null 2>&1; then
    MODE="kind"
  else
    MODE="minikube"
  fi
fi

echo "Mode: $MODE"

echo "Construindo a imagem Docker..."
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

if [ "$MODE" = "kind" ]; then
  CLUSTER_NAME="${KIND_CLUSTER:-desafio-devops}"
  if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Kind nao esta rodando. Criando cluster ${CLUSTER_NAME}..."
    kind create cluster --name ${CLUSTER_NAME}
  fi

  echo "Carregando imagem no Kind..."
  kind load docker-image ${IMAGE_NAME}:${VERSION} --name ${CLUSTER_NAME}

  echo "Aplicando manifestos Kubernetes..."
  kubectl apply -f k8s/
  kubectl set image deployment/desafio-devops-app-deployment desafio-devops-app=${IMAGE_NAME}:${VERSION}
  kubectl rollout status deployment/desafio-devops-app-deployment

  echo "Deploy concluido no Kind."
else
  if ! minikube status | grep -q "Running"; then
    echo "Minikube nao esta rodando. Iniciando..."
    minikube start
  fi

  echo "Aplicando manifestos Kubernetes..."
  kubectl apply -f k8s/
  kubectl rollout status deployment/desafio-devops-app-deployment

  echo "Aplicacao deployada! Acesse em:"
  minikube service desafio-devops-app-service --url
fi
