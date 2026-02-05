#!/bin/bash

# Script para automatizar o deploy da aplicação no Minikube

# Verifica se o Minikube está rodando
if ! minikube status | grep -q "Running"; then
  echo "Minikube não está rodando. Iniciando..."
  minikube start
fi

# Constrói a imagem Docker
echo "Construindo a imagem Docker..."
docker build -t rafaelbastos/desafio-devops-app:latest .

# Aplica os manifestos Kubernetes
echo "Aplicando manifestos Kubernetes..."
kubectl apply -f k8s/

# Espera o deployment estar pronto
echo "Aguardando o deployment estar pronto..."
kubectl rollout status deployment/desafio-devops-app-deployment

# Exibe a URL da aplicação
echo "Aplicação deployada! Acesse em:"
minikube service desafio-devops-app-service --url

echo "Deploy concluído com sucesso!"
