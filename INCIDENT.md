# Incidente Simulado: Aplicação Parou de Responder Após Deploy Noturno

## Cenário

Durante um deploy noturno, a aplicação parou de responder após o pipeline executar com sucesso.

## Investigação do Problema

1.  **Verificação Inicial do Status:**
    -   `kubectl get pods`: Verificar o status dos Pods. Estão `Running`? Há algum `CrashLoopBackOff`?
    -   `kubectl get deployments`: Verificar o status do Deployment. Está com o número de réplicas desejado?
    -   `kubectl get services`: Verificar se o Service está apontando para os Pods corretos.

2.  **Análise de Logs:**
    -   `kubectl logs <nome-do-pod>`: Acessar os logs da aplicação para identificar erros ou exceções.
    -   `kubectl describe pod <nome-do-pod>`: Obter informações detalhadas sobre o Pod, incluindo eventos e condições.

3.  **Verificação de Métricas (Prometheus/Grafana):**
    -   Acessar o Prometheus (`http://localhost:9090`) e o Grafana (`http://localhost:3000`) para verificar as métricas da aplicação. Houve queda nas requisições? A latência aumentou? Há erros HTTP 5xx?
    -   Comparar as métricas com o comportamento normal da aplicação.

4.  **Testes de Conectividade:**
    -   `kubectl exec -it <nome-do-pod> -- curl localhost:5000/health`: Testar o endpoint de saúde diretamente de dentro do Pod.
    -   `kubectl exec -it <nome-do-pod> -- ping <nome-do-servico-externo>`: Se a aplicação depende de serviços externos (banco de dados, APIs), verificar a conectividade.

5.  **Verificação de Configuração:**
    -   `kubectl get configmaps` e `kubectl get secrets`: Verificar se alguma configuração ou segredo foi alterado e está causando o problema.

## Ferramentas Usadas

-   `kubectl`: Para interagir com o cluster Kubernetes (status de Pods, logs, eventos).
-   `docker`: Para verificar a imagem localmente, se necessário.
-   **Prometheus/Grafana**: Para monitoramento de métricas e identificação de anomalias.
-   `curl`: Para testar endpoints da aplicação.
-   `git log`: Para verificar alterações recentes no código ou nos manifestos.

## Possíveis Causas

-   **Erro na Aplicação:** Um bug no código da nova versão que só se manifesta em produção ou sob certas condições.
-   **Configuração Incorreta:** Um `ConfigMap` ou `Secret` mal configurado que a aplicação não consegue ler ou que a faz se comportar de forma inesperada.
-   **Problemas de Recursos:** A nova versão da aplicação está consumindo mais CPU/memória do que o esperado, causando `OOMKilled` (Out Of Memory Killed) ou lentidão extrema.
-   **Dependência Externa:** Um serviço externo (banco de dados, cache, API de terceiros) que a aplicação depende está com problemas ou inacessível.
-   **Problemas de Rede:** Configuração de rede no Kubernetes (Service, Ingress) que impede o tráfego de chegar à aplicação.
-   **Liveness/Readiness Probes Mal Configurados:** Probes que estão falhando incorretamente, fazendo o Kubernetes reiniciar ou não direcionar tráfego para Pods saudáveis.

## Estratégia de Rollback

1.  **Rollback do Deployment:**
    -   A maneira mais rápida de reverter é usar o histórico de revisões do Deployment:
        ```bash
        kubectl rollout undo deployment/desafio-devops-app-deployment
        ```
    -   Isso reverterá para a versão anterior do Deployment, que estava funcionando.

2.  **Monitoramento Pós-Rollback:**
    -   Após o rollback, monitorar de perto os logs e métricas para garantir que a aplicação voltou ao normal.

## Como Evitar que Isso Aconteça Novamente

-   **Testes Mais Abrangentes:** Implementar testes de integração e end-to-end mais robustos no pipeline de CI/CD para capturar bugs antes do deploy.
-   **Ambientes de Staging:** Ter um ambiente de `staging` (pré-produção) que simule o ambiente de produção o mais fielmente possível para testes finais.
-   **Monitoramento e Alertas:** Configurar alertas proativos no Prometheus/Grafana para anomalias nas métricas (ex: aumento de erros 5xx, queda de requisições) que notifiquem a equipe imediatamente.
-   **Estratégias de Deploy Gradual:** Implementar Blue/Green ou Canary Deploy para liberar novas versões gradualmente, minimizando o impacto de um problema.
-   **Revisão de Código e Configuração:** Realizar revisões de código e manifestos Kubernetes por pares para identificar potenciais problemas antes do deploy.
-   **Post-Mortem:** Após resolver o incidente, realizar uma análise `post-mortem` para entender a causa raiz, documentar lições aprendidas e implementar ações corretivas.
