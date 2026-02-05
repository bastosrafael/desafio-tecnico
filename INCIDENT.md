# Incidente Simulado

## Cenário
Durante um deploy noturno, a aplicacao parou de responder apos o pipeline executar com sucesso.

## Como eu investigaria
1. Verificar status dos pods e do deployment:

```bash
kubectl get pods
kubectl get deploy
kubectl get svc
```

2. Ver logs da aplicacao:

```bash
kubectl logs deploy/desafio-devops-app-deployment
```

3. Ver detalhes do pod (eventos, erros de probe, OOM):

```bash
kubectl describe pod <nome-do-pod>
```

4. Testar o endpoint direto no pod:

```bash
kubectl exec -it <nome-do-pod> -- curl -s http://localhost:5000/health
```

5. Verificar se as metricas continuam chegando:

```bash
kubectl port-forward svc/desafio-devops-app-service 8000:8000
curl -s http://localhost:8000/metrics | head -n 20
```

6. Verificar no Prometheus/Grafana:

```bash
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
```

## Possiveis causas
- Bug na nova versao da aplicacao
- Probe configurada de forma errada
- Falta de recursos (CPU/memoria) gerando OOM
- Dependencia externa fora do ar
- Problema de rede ou service

## Rollback simples

```bash
kubectl rollout undo deployment/desafio-devops-app-deployment
kubectl rollout status deployment/desafio-devops-app-deployment
```

## Como evitar no futuro
- Mais testes automatizados no CI
- Validar probes e limites de recursos
- Deploy gradual (canary/blue-green)
- Alertas no Prometheus/Grafana
- Revisao de manifestos antes do deploy

## Comandos que usei neste desafio

```bash
kubectl apply -f k8s/
kubectl rollout restart deployment/desafio-devops-app-deployment
kubectl rollout status deployment/desafio-devops-app-deployment
kubectl port-forward svc/desafio-devops-app-service 8000:8000
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
kubectl get svc
kubectl get pods
kubectl exec -it deploy/desafio-devops-app-deployment -- sh -c "ss -tlnp | grep 8000 || netstat -tlnp | grep 8000"
```
