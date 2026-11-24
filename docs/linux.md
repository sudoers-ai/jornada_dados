# 🐧 Preparando o Ubuntu

> ⬅️ [README principal](../README.md)

No Linux o Docker roda direto no sistema: é o ambiente mais simples para a
trilha. Você prepara uma vez e usa na jornada inteira.

Os comandos abaixo são para o **Ubuntu 22.04 ou 24.04** (servem também para
derivados, como Linux Mint e Pop!_OS).

| Passo | O que instala | Comando principal |
|---|---|---|
| 1 | Docker Engine e Docker Compose v2 | `curl -fsSL https://get.docker.com \| sh` |
| 2 | Permissão para usar o Docker sem `sudo` | `sudo usermod -aG docker $USER` |
| 3 | `make`, `git` e o Python dos geradores de dados | `sudo apt install make git python3-venv` |
| 4 | O repositório | `git clone ...` |
| 5 | Subir e conferir | `make subir` e `make status` |

> **Já tem Docker?** Confira com `docker compose version` (com espaço). Se
> responder com um número de versão, pule para o passo 3.

---

## Passo 1 — Instalar o Docker

O script oficial da Docker detecta a sua distribuição e instala o Docker
Engine **com** o Compose v2:

```bash
curl -fsSL https://get.docker.com -o instalar-docker.sh
sudo sh instalar-docker.sh
```

Ele pede a sua senha (a do `sudo`; ao digitar nada aparece na tela, é
normal) e leva um ou dois minutos. Confira:

```bash
sudo docker run --rm hello-world
```

Tem que aparecer `Hello from Docker!`.

> ⚠️ **Evite o Docker do Snap** (`snap install docker`, ou a "Ubuntu
> Software"). Ele roda com restrições que causam erros estranhos de
> permissão em pastas. Se você o tem, remova (`sudo snap remove docker`) e
> instale pelo passo acima.

---

## Passo 2 — Usar o Docker sem `sudo`

```bash
sudo usermod -aG docker $USER
```

**Saia da sessão e entre de novo** (ou reinicie o computador): o grupo novo
só vale para sessões novas. Confira, agora **sem** `sudo`:

```bash
docker run --rm hello-world
docker compose version
```

Os dois têm que funcionar. Se aparecer `permission denied while trying to
connect to the Docker daemon`, a sessão ainda é a antiga: saia e entre de
novo.

---

## Passo 3 — Instalar o `make`, o `git` e o Python

```bash
sudo apt update && sudo apt install -y make git python3-venv python3-pip
```

Confira:

```bash
make --version
```

```text
GNU Make 4.3
```

O `make` é o que dá os atalhos `make status` e `make conferir`.

Os geradores de dados da trilha (`airflow_dags/liga_sudoers_*.py`) rodam na
sua máquina e usam duas bibliotecas Python. Instale-as num ambiente virtual,
para não mexer no Python do sistema:

```bash
python3 -m venv ~/.venv-jornada
source ~/.venv-jornada/bin/activate
pip install psycopg2-binary Faker
```

Confira:

```bash
python -c "import psycopg2, faker; print('ok')"
```

> O `source ~/.venv-jornada/bin/activate` vale só para o terminal em que foi
> digitado. Num terminal novo, rode-o de novo antes de usar um gerador (o
> começo da linha passa a mostrar `(.venv-jornada)`).

---

## Passo 4 — Baixar o repositório

```bash
cd ~
git clone https://github.com/sudoers-ai/jornada_dados.git
cd jornada_dados
```

---

## Passo 5 — Subir e conferir

```bash
make subir
make status
```

A primeira vez baixa as imagens (alguns GB): pode levar vários minutos. O
`make status` tem que mostrar os 8 serviços no ar:

```text
  serviços  8 de 8 no ar
   ● postgres_oltp  ● postgres_olap  ● minio  ● spark  ● zookeeper  ● kafka  ● debezium  ● airflow
```

Pronto. Volte ao [README principal](../README.md)
e siga a partir do **Modo Terminal — MinIO**. Ao fim de cada etapa,
`make conferir e=N` diz se ela ficou certa.

> **Memória.** Com os 8 serviços no ar e parados, os containers ocupam cerca
> de 3 GB. O `spark-sql` e o `dbt` pedem mais enquanto rodam. Feche o que
> não estiver usando.

---

## Dicas para o dia a dia no Linux

**Colar no terminal.** Na maioria dos terminais, `Ctrl+Shift+V` (o `Ctrl+V`
sozinho não funciona).

**Vários terminais.** A trilha pede mais de um terminal: um dentro de um
container (`docker exec -it spark bash`) e outro na sua máquina, para o
`make conferir`. `Ctrl+Shift+T` abre uma nova aba. Numa janela nova, entre
na pasta com `cd ~/jornada_dados`.

**Ao fim da sessão.** `make parar` para os serviços e **mantém** o seu
progresso. Na próxima: `cd ~/jornada_dados` e `make subir`.

---

## 🆘 Problemas comuns no Linux

| O que apareceu | O que é | O que fazer |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon` | Seu usuário não está no grupo `docker`, ou a sessão é anterior ao `usermod` | Passo 2, e saia e entre de novo na sessão |
| `Cannot connect to the Docker daemon` | O serviço do Docker está parado | `sudo systemctl start docker` |
| `docker: 'compose' is not a docker command` | Docker sem o Compose v2 | `sudo apt install docker-compose-v2` (pacote do Ubuntu) ou `sudo apt install docker-compose-plugin` (repositório da Docker) |
| `make: command not found` | Faltou o passo 3 | `sudo apt install make` |
| `port is already allocated` no `make subir` | Outro programa usa uma das portas da trilha | Veja as [portas no README](../README.md#-pré-requisitos-checklist-rápido) e pare o programa que ocupa a porta |
| `error: externally-managed-environment` no `pip install` | Você rodou o `pip` fora do ambiente virtual | `source ~/.venv-jornada/bin/activate` e repita |

Veja também o [FAQ](./faq.md).
