# Guia Passo a Passo para Execução Local do Desafio DevOps

Este guia detalha os passos para configurar e executar o desafio técnico DevOps em seu ambiente local, antes de subir o projeto para o GitHub. Ele é focado em iniciantes e utiliza exemplos práticos para facilitar a compreensão.

## 1. Pré-requisitos e Configuração do Ambiente Local

Antes de começar, você precisará instalar algumas ferramentas essenciais em seu notebook.

### 1.1. Docker

**O que é:** Docker é uma plataforma que permite empacotar aplicações e suas dependências em containers, garantindo que elas funcionem de forma consistente em qualquer ambiente.

**Por que está aqui:** A Parte 1 do desafio exige a containerização da aplicação usando Docker.

**Como instalar:**

- **Windows/macOS:** Baixe e instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/). Ele inclui o Docker Engine, Docker CLI, Docker Compose e Kubernetes (opcional).
- **Linux:** Siga as instruções específicas para sua distribuição em [docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

**Verificar instalação:** Abra o terminal e execute:

```bash
docker --version
```

### 1.2. Git

**O que é:** Git é um sistema de controle de versão distribuído, usado para rastrear mudanças no código-fonte durante o desenvolvimento de software.

**Por que está aqui:** Você precisará do Git para clonar o repositório do desafio e, posteriormente, para subir seu projeto para o GitHub.

**Como instalar:**

- **Windows:** Baixe e instale o [Git for Windows](https://gitforwindows.org/).
- **macOS:** Pode ser instalado via Homebrew (`brew install git`) ou Xcode Command Line Tools (`xcode-select --install`).
- **Linux:** Geralmente disponível no gerenciador de pacotes da sua distribuição (ex: `sudo apt install git` no Debian/Ubuntu, `sudo yum install git` no CentOS/RHEL).

**Verificar instalação:** Abra o terminal e execute:

```bash
git --version
```

### 1.3. Minikube (ou Kind/K3s)

**O que é:** Minikube é uma ferramenta que executa um cluster Kubernetes de nó único em sua máquina local. Kind (Kubernetes in Docker) e K3s são alternativas leves.

**Por que está aqui:** A Parte 3 do desafio exige a implantação da aplicação em Kubernetes. Um cluster local é ideal para desenvolvimento e testes.

**Como instalar (Minikube - recomendado para iniciantes):**

1. **Instalar um driver de virtualização:** Minikube precisa de um driver como VirtualBox, Hyper-V (Windows), KVM (Linux) ou Docker (se você já tem o Docker Desktop, ele pode ser o driver).
2. **Instalar `kubectl`:** A ferramenta de linha de comando para interagir com clusters Kubernetes.
   - Siga as instruções em [kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
3. **Instalar Minikube:**
   - Siga as instruções em [minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)

**Verificar instalação:**

```bash
minikube version
kubectl version --client
```

**Iniciar Minikube:**

```bash
minikube start
```

### 1.4. Editor de Código (VS Code - recomendado)

**O que é:** Um editor de texto avançado para escrever código, com recursos como realce de sintaxe, autocompletar e integração com Git.

**Por que está aqui:** Você precisará de um bom editor para escrever o código da aplicação, Dockerfile, manifestos Kubernetes e scripts.

**Como instalar:** Baixe e instale o [Visual Studio Code](https://code.visualstudio.com/).

## 2. Estrutura do Projeto (Exemplo)

Para este guia, vamos considerar uma estrutura de projeto básica. Você pode adaptar conforme a linguagem de programação escolhida para o backend.

```
 desafio-devops/
 ├── app/                  # Código-fonte da aplicação backend
 │   ├── main.py
 │   ├── requirements.txt
 │   └── ...
 ├── Dockerfile            # Instruções para construir a imagem Docker
 ├── k8s/                  # Manifestos Kubernetes
 │   ├── deployment.yaml
 │   └── service.yaml
 ├── .github/              # Configuração do GitHub Actions (se escolhido)
 │   └── workflows/
 │       └── ci-cd.yaml
 ├── scripts/              # Scripts de automação (Parte 5)
 │   └── deploy.sh
 ├── INCIDENT.md           # Resposta ao incidente simulado (Parte 6)
 └── README.md             # Documentação do projeto
```

## 3. Desenvolvimento da Aplicação Backend (Exemplo Python Flask)

Vamos criar uma aplicação Flask simples que atenda aos requisitos da Parte 1 e 4.

### 3.1. Criar a Aplicação

No diretório `app/`, crie um arquivo `main.py` com o seguinte conteúdo:

```python
# app/main.py
from flask import Flask, jsonify
from prometheus_client import generate_latest, Counter, Histogram
import time

app = Flask(__name__)

# Métricas Prometheus
REQUESTS = Counter("http_requests_total", "Total HTTP Requests", ["method", "endpoint", "status_code"])
LATENCY = Histogram("http_request_duration_seconds", "HTTP Request Latency", ["method", "endpoint"])

@app.route("/")
def home():
    start_time = time.time()
    REQUESTS.labels(method="GET", endpoint="/", status_code=200).inc()
    LATENCY.labels(method="GET", endpoint="/").observe(time.time() - start_time)
    return "Hello, DevOps Challenge!"

@app.route("/health")
def health():
    start_time = time.time()
    REQUESTS.labels(method="GET", endpoint="/health", status_code=200).inc()
    LATENCY.labels(method="GET", endpoint="/health").observe(time.time() - start_time)
    return jsonify(status="UP")

@app.route("/ready")
def ready():
    start_time = time.time()
    REQUESTS.labels(method="GET", endpoint="/ready", status_code=200).inc()
    LATENCY.labels(method="GET", endpoint="/ready").observe(time.time() - start_time)
    # Aqui você adicionaria lógica para verificar se a aplicação está pronta (ex: conexão com DB)
    return jsonify(status="READY")

@app.route("/metrics")
def metrics():
    start_time = time.time()
    REQUESTS.labels(method="GET", endpoint="/metrics", status_code=200).inc()
    LATENCY.labels(method="GET", endpoint="/metrics").observe(time.time() - start_time)
    return generate_latest().decode("utf-8")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Crie também um arquivo `requirements.txt` no diretório `app/`:

```
# app/requirements.txt
Flask==2.3.2
prometheus_client==0.17.1
```

### 3.2. Testar a Aplicação Localmente (sem Docker)

1. Navegue até o diretório `app/` no terminal:
   ```bash
   cd desafio-devops/app
   ```
2. Crie um ambiente virtual (recomendado):
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # No Windows: .\venv\Scripts\activate
   ```
3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
4. Execute a aplicação:
   ```bash
   python main.py
   ```
5. Abra seu navegador ou use `curl` para testar os endpoints:
   - `http://localhost:5000/`
   - `http://localhost:5000/health`
   - `http://localhost:5000/ready`
   - `http://localhost:5000/metrics`

## 4. Containerização com Docker (Parte 1)

Agora, vamos criar o Dockerfile para a aplicação.

### 4.1. Criar Dockerfile

No diretório `desafio-devops/`, crie um arquivo `Dockerfile` com o seguinte conteúdo:

```dockerfile
# Dockerfile

# Stage 1: Build stage
FROM python:3.9-slim-buster as builder

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

# Stage 2: Run stage
FROM python:3.9-slim-buster

WORKDIR /app

# Criar um usuário não-root
RUN adduser --system --group appuser
USER appuser

COPY --from=builder /app /app

EXPOSE 5000

CMD ["python", "main.py"]
```

**Explicação do Dockerfile:**

- `FROM python:3.9-slim-buster as builder`: Define a imagem base para a etapa de construção (`builder`). Usamos uma imagem `slim` para ser mais leve e `buster` para a distribuição Debian.
- `WORKDIR /app`: Define o diretório de trabalho dentro do container.
- `COPY app/requirements.txt .`: Copia o arquivo de dependências da sua aplicação para o diretório de trabalho.
- `RUN pip install --no-cache-dir -r requirements.txt`: Instala as dependências Python. `--no-cache-dir` ajuda a manter a imagem menor.
- `COPY app/ .`: Copia o restante do código da aplicação para o diretório de trabalho.

- `FROM python:3.9-slim-buster`: Inicia uma nova etapa de construção, usando a mesma imagem base, mas sem as ferramentas de build da etapa anterior. Isso é o **multi-stage build**.
- `WORKDIR /app`: Define o diretório de trabalho para a etapa de execução.
- `RUN adduser --system --group appuser`: Cria um novo usuário e grupo (`appuser`) sem privilégios de root. Isso atende ao requisito de **não rodar como root**.
- `USER appuser`: Define que os comandos subsequentes serão executados com o usuário `appuser`.
- `COPY --from=builder /app /app`: Copia apenas os arquivos necessários da etapa `builder` para a etapa final, resultando em uma **imagem leve e segura**.
- `EXPOSE 5000`: Informa que o container irá expor a porta 5000.
- `CMD ["python", "main.py"]`: Define o comando que será executado quando o container iniciar.

### 4.2. Construir a Imagem Docker

No diretório `desafio-devops/`, execute o comando para construir a imagem. Lembre-se de substituir `seu-usuario-docker` pelo seu nome de usuário do Docker Hub e `desafio-devops-app` pelo nome da sua aplicação.

```bash
docker build -t seu-usuario-docker/desafio-devops-app:1.0.0 -t seu-usuario-docker/desafio-devops-app:latest .
```

**Explicação:**

- `docker build`: Comando para construir uma imagem Docker.
- `-t seu-usuario-docker/desafio-devops-app:1.0.0`: Atribui uma tag semântica (`1.0.0`) à imagem, seguindo o requisito de **versionar a imagem**. `seu-usuario-docker` é o namespace no Docker Hub.
- `-t seu-usuario-docker/desafio-devops-app:latest`: Atribui também a tag `latest`, que geralmente aponta para a versão mais recente.
- `.`: Indica que o Dockerfile está no diretório atual.

### 4.3. Testar a Imagem Docker Localmente

Execute o container a partir da imagem que você acabou de construir:

```bash
docker run -p 5000:5000 seu-usuario-docker/desafio-devops-app:latest
```

**Explicação:**

- `docker run`: Comando para executar um container.
- `-p 5000:5000`: Mapeia a porta 5000 do seu host para a porta 5000 do container, permitindo que você acesse a aplicação.
- `seu-usuario-docker/desafio-devops-app:latest`: O nome da imagem e a tag a serem usadas.

Verifique novamente os endpoints no navegador ou com `curl`:

- `http://localhost:5000/`
- `http://localhost:5000/health`
- `http://localhost:5000/ready`
- `http://localhost:5000/metrics`

You must see the same responses as before, but now the application is running inside a Docker container.

## 5. Implantação no Kubernetes Local (Parte 3)

Vamos implantar a aplicação no Minikube (ou seu cluster Kubernetes local).

### 5.1. Criar Manifestos Kubernetes

Crie o diretório `k8s/` e dentro dele, crie os arquivos `deployment.yaml` e `service.yaml`.

**`k8s/deployment.yaml`:**

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: desafio-devops-app-deployment
  labels:
    app: desafio-devops-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: desafio-devops-app
  template:
    metadata:
      labels:
        app: desafio-devops-app
    spec:
      containers:
      - name: desafio-devops-app
        image: seu-usuario-docker/desafio-devops-app:latest # Use a imagem que você construiu
        ports:
        - containerPort: 5000
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Explicação do `deployment.yaml`:**

- `apiVersion`, `kind`, `metadata`: Informações básicas para o Kubernetes identificar o tipo de recurso e seus metadados.
- `replicas: 1`: Garante que sempre haverá uma instância da sua aplicação rodando. Você pode aumentar para mais réplicas para alta disponibilidade.
- `selector` e `template/labels`: Usados para o Deployment encontrar e gerenciar os Pods corretos.
- `containers/name`, `image`, `ports`: Define o container da sua aplicação, a imagem Docker a ser usada e a porta que ele expõe.
- `resources/requests` e `limits`: Define a quantidade de CPU e memória que o container **solicita** (requests) e o **máximo** que ele pode usar (limits). Isso é crucial para o gerenciamento de recursos no cluster.
- `livenessProbe`: Configura uma verificação de saúde que reinicia o container se o endpoint `/health` não responder. Garante que a aplicação esteja sempre funcional.
- `readinessProbe`: Configura uma verificação de saúde que impede que o tráfego seja direcionado ao container até que o endpoint `/ready` responda. Garante que a aplicação esteja pronta para receber requisições.

**`k8s/service.yaml`:**

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: desafio-devops-app-service
spec:
  selector:
    app: desafio-devops-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: NodePort # Ou LoadBalancer se estiver em um cluster real na nuvem
```

**Explicação do `service.yaml`:**

- `apiVersion`, `kind`, `metadata`: Informações básicas para o Kubernetes.
- `selector`: Seleciona os Pods (instâncias da sua aplicação) que este serviço irá expor, usando os mesmos `labels` definidos no Deployment.
- `ports`: Define como o serviço irá expor a aplicação:
  - `protocol: TCP`: O protocolo de comunicação.
  - `port: 80`: A porta que o serviço irá expor dentro do cluster (e externamente, dependendo do `type`).
  - `targetPort: 5000`: A porta do container onde a aplicação está rodando.
- `type: NodePort`: Expõe o serviço em uma porta em cada nó do cluster. Isso permite que você acesse a aplicação de fora do cluster (ideal para Minikube). Em um ambiente de nuvem, você usaria `LoadBalancer` para obter um IP público.

### 5.2. Aplicar os Manifestos no Minikube

Certifique-se de que seu Minikube esteja rodando (`minikube start`). Em seguida, no diretório `desafio-devops/`, execute:

```bash
kubectl apply -f k8s/
```

**Explicação:**

- `kubectl apply -f k8s/`: Aplica todos os arquivos YAML encontrados no diretório `k8s/` ao seu cluster Kubernetes. Isso criará o Deployment e o Service.

### 5.3. Verificar o Deploy e Acessar a Aplicação

Verifique se os Pods e o Service foram criados e estão rodando:

```bash
kubectl get pods
kubectl get services
```

Para acessar a aplicação rodando no Minikube, você pode usar o comando `minikube service`:

```bash
minikube service desafio-devops-app-service --url
```

Este comando irá abrir a URL da sua aplicação no navegador ou exibir a URL no terminal. Teste os endpoints `/`, `/health`, `/ready` e `/metrics` novamente.

## 6. Observabilidade (Parte 4)

Para a observabilidade, vamos configurar o Prometheus para coletar as métricas da sua aplicação no Minikube.

### 6.1. Instalar Prometheus no Minikube

A maneira mais fácil de instalar o Prometheus em um cluster Kubernetes local é usando o Helm, um gerenciador de pacotes para Kubernetes.

1. **Instalar Helm:** Siga as instruções em [helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/).
2. **Adicionar o repositório Prometheus Community Helm:**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```
3. **Instalar Prometheus:**
   ```bash
   helm install prometheus prometheus-community/prometheus
   ```

### 6.2. Configurar o Prometheus para Scrapear sua Aplicação

Por padrão, o Prometheus instalado via Helm já deve estar configurado para descobrir serviços no Kubernetes. No entanto, para garantir que ele colete as métricas da sua aplicação, você pode precisar de um `ServiceMonitor` ou configurar manualmente o `scrape_config` no Prometheus.

Para simplificar para iniciantes, vamos assumir que o Prometheus detectará automaticamente o endpoint `/metrics` do seu serviço, já que ele segue as convenções do Kubernetes. Se não funcionar, você precisaria editar a configuração do Prometheus para adicionar um `scrape_config` específico para seu serviço.

### 6.3. Acessar o Dashboard do Prometheus

Para acessar a interface web do Prometheus:

```bash
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090:9090
```

Abra seu navegador em `http://localhost:9090`. Na interface do Prometheus, você pode usar a barra de pesquisa para buscar as métricas da sua aplicação, como `http_requests_total` ou `http_request_duration_seconds_bucket`.

### 6.4. (Opcional) Instalar Grafana no Minikube

Para criar dashboards visuais:

1. **Instalar Grafana:**
   ```bash
   helm install grafana prometheus-community/grafana
   ```
2. **Obter a senha de administrador do Grafana:**
   ```bash
   kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode
   ```
3. **Acessar o Dashboard do Grafana:**
   ```bash
   kubectl port-forward service/grafana 3000:80
   ```

Abra seu navegador em `http://localhost:3000`. Faça login com `admin` e a senha que você obteve. Você pode então adicionar o Prometheus como fonte de dados e criar seus dashboards.

## 7. Automação (Parte 5)

Vamos criar um script Bash simples para automatizar o deploy da aplicação no Minikube.

### 7.1. Criar Script de Automação

No diretório `desafio-devops/scripts/`, crie um arquivo `deploy.sh` com o seguinte conteúdo:

```bash
#!/bin/bash

# Script para automatizar o deploy da aplicação no Minikube

# Verifica se o Minikube está rodando
if ! minikube status | grep -q "Running"; then
  echo "Minikube não está rodando. Iniciando..."
  minikube start
fi

# Constrói a imagem Docker
echo "Construindo a imagem Docker..."
docker build -t seu-usuario-docker/desafio-devops-app:latest .

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
```

**Explicação do `deploy.sh`:**

- `#!/bin/bash`: Shebang, indica que o script deve ser executado com Bash.
- `minikube status`: Verifica o status do Minikube.
- `docker build`: Constrói a imagem Docker.
- `kubectl apply -f k8s/`: Aplica os manifestos Kubernetes.
- `kubectl rollout status`: Espera até que o deployment esteja completamente atualizado e pronto.
- `minikube service --url`: Obtém a URL da aplicação no Minikube.

### 7.2. Tornar o Script Executável e Rodar

No terminal, no diretório `desafio-devops/`:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Este script automatiza todo o processo de construção da imagem, aplicação dos manifestos e exibição da URL, simulando um deploy automatizado.

## 8. Incidente Simulado (Parte 6)

Crie o arquivo `INCIDENT.md` no diretório `desafio-devops/` e responda à situação proposta.

### 8.1. Conteúdo do `INCIDENT.md`

```markdown
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
```

## 9. Próximos Passos: Subindo para o GitHub

Depois de ter tudo funcionando localmente e a documentação pronta, você pode subir seu projeto para o GitHub.

1.  **Inicializar um repositório Git (se ainda não o fez):**
    ```bash
    cd desafio-devops
    git init
    ```
2.  **Adicionar seus arquivos:**
    ```bash
    git add .
    ```
3.  **Fazer o primeiro commit:**
    ```bash
    git commit -m "Initial commit: DevOps Challenge solution"
    ```
4.  **Criar um repositório no GitHub:** Vá para [github.com/new](https://github.com/new) e crie um novo repositório público.
5.  **Adicionar o repositório remoto e fazer o push:**
    ```bash
    git remote add origin <URL_DO_SEU_REPOSITORIO_GITHUB>
    git push -u origin master # Ou main, dependendo da sua branch padrão
    ```

Este guia oferece uma base sólida para você iniciar o desafio. Boa sorte!
