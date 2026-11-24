# 🪟 Preparando o Windows

> ⬅️ [README principal](../README.md)

Este repositório roda em Linux. No Windows, isso se resolve com o **WSL2**: um
Linux de verdade rodando dentro do Windows, mantido pela Microsoft. Você
prepara uma vez e usa na jornada inteira.

| Passo | O que instala | Onde |
|---|---|---|
| 1 | WSL2 com Ubuntu | PowerShell |
| 2 | O Docker: **A)** Docker Desktop **ou B)** Docker Engine dentro do Ubuntu | Windows ou terminal do Ubuntu |
| 3 | `make`, `git` e o Python dos geradores de dados | terminal do Ubuntu |
| 4 | O repositório | terminal do Ubuntu |
| 5 | Subir e conferir | terminal do Ubuntu |

> ⚠️ **A regra que evita quase todos os problemas:** depois do passo 1,
> **todos os comandos da trilha são digitados no terminal do Ubuntu**, nunca
> no PowerShell nem no Prompt de Comando. O PowerShell não tem `make` e não
> roda os scripts do repositório.

---

## Passo 1 — Instalar o WSL2 com Ubuntu

Abra o **PowerShell como administrador** (clique com o botão direito no menu
Iniciar → *Terminal (Admin)* ou *Windows PowerShell (Admin)*) e rode:

```powershell
wsl --install
```

**Reinicie o computador** quando terminar.

Depois de reiniciar, o Ubuntu abre sozinho e pede para você criar um **usuário
e uma senha do Linux**. Pode ser qualquer um; anote a senha, você vai usá-la
quando um comando começar com `sudo`. (Ao digitar a senha nada aparece na
tela. É normal.)

Confira, ainda no PowerShell:

```powershell
wsl -l -v
```

Tem que aparecer o Ubuntu com **VERSION 2**:

```text
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

> Se aparecer `VERSION 1`, converta com `wsl --set-version Ubuntu 2`.
>
> Se o `wsl --install` disser que o WSL já está instalado mas não houver
> nenhuma distribuição, rode `wsl --install -d Ubuntu`.
>
> **A Microsoft Store está bloqueada** (o download do Ubuntu não sai do
> lugar)? Use `wsl --install -d Ubuntu --web-download`, que baixa direto,
> sem a loja.

**Como abrir o terminal do Ubuntu daqui em diante:** menu Iniciar → digite
**Ubuntu** → Enter. É nele que você vai trabalhar.

---

## Passo 2 — Instalar o Docker

Há dois caminhos. Os dois rodam a trilha igual; escolha **um**:

| | **A) Docker Desktop** | **B) Docker Engine dentro do Ubuntu** |
|---|---|---|
| Quando usar | computador pessoal, ou empresa **com** licença do Docker Desktop | computador da empresa **sem** licença do Docker Desktop |
| Licença | grátis para uso pessoal e empresas pequenas; **paga** em empresas grandes | grátis (código aberto) |
| Como é | programa do Windows, com a baleia na bandeja | serviço do Ubuntu, sem janela |
| No começo de cada sessão | abrir o Docker Desktop | nada: sobe junto com o Ubuntu |

### Opção A — Docker Desktop

1. Baixe e instale o **Docker Desktop para Windows**:
   https://www.docker.com/products/docker-desktop
2. Abra o Docker Desktop e espere o ícone da baleia parar de se mexer.
3. Vá em **Settings** (a engrenagem) → **General** e confirme que
   **Use the WSL 2 based engine** está marcado.
4. Vá em **Settings → Resources → WSL Integration** e ligue a chave do
   **Ubuntu**. Clique em **Apply & restart**.

Confira, agora **no terminal do Ubuntu**:

```bash
docker --version
docker compose version
```

Os dois têm que responder com um número de versão.

> **O Docker Desktop precisa estar aberto** sempre que você for trabalhar na
> trilha. Se o terminal responder `Cannot connect to the Docker daemon`, é
> porque ele está fechado.

Pule para o [passo 3](#passo-3--instalar-o-make-o-git-e-o-python).

### Opção B — Docker Engine dentro do Ubuntu (sem Docker Desktop)

O **Docker Engine**, que é o Docker propriamente dito, é gratuito e roda
direto no Ubuntu do WSL. Tudo abaixo é no **terminal do Ubuntu**, menos o
`wsl --shutdown`, que é no PowerShell.

> Tem o Docker Desktop instalado? Não misture os dois: desligue a integração
> com o Ubuntu (Docker Desktop → Settings → Resources → WSL Integration) ou
> desinstale o Docker Desktop antes.

**B1. Ligue o systemd no Ubuntu.** É ele que mantém o Docker rodando:

```bash
grep -qs '^systemd=true' /etc/wsl.conf || printf '\n[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf
```

Feche o Ubuntu e, no **PowerShell** (não precisa ser administrador):

```powershell
wsl --shutdown
```

Abra o Ubuntu de novo e confira: `systemctl is-system-running` tem que
responder `running` ou `degraded` (os dois servem).

**B2. Instale o Docker Engine** com o script oficial da Docker:

```bash
curl -fsSL https://get.docker.com -o instalar-docker.sh
sudo sh instalar-docker.sh
```

O script avisa que você está no WSL e recomenda o Docker Desktop. **Espere:**
ele continua sozinho em 20 segundos. Leva um ou dois minutos.

**B3. Use o Docker sem `sudo`:**

```bash
sudo usermod -aG docker $USER
```

O grupo novo só vale numa sessão nova: feche o Ubuntu, rode `wsl --shutdown`
no PowerShell e abra o Ubuntu de novo.

**B4. Confira**, agora **sem** `sudo`:

```bash
docker run --rm hello-world
docker compose version
```

Tem que aparecer `Hello from Docker!` e um número de versão. Se aparecer
`permission denied`, a sessão ainda é a antiga: repita o `wsl --shutdown`.

> Nesse modo **não existe a baleia**. O Docker sobe junto com o Ubuntu. Se
> um dia ele não responder (`Cannot connect to the Docker daemon`), rode
> `sudo systemctl start docker`.

---

## Passo 3 — Instalar o `make`, o `git` e o Python

No terminal do Ubuntu:

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

Os geradores de dados da trilha (`airflow_dags/liga_sudoers_*.py`) rodam no
Ubuntu, fora dos containers, e usam duas bibliotecas Python. Instale-as num
ambiente virtual, para não mexer no Python do sistema:

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

## Passo 4 — Baixar o repositório no lugar certo

No terminal do Ubuntu:

```bash
cd ~
git clone https://github.com/sudoers-ai/jornada_dados.git
cd jornada_dados
```

> ⚠️ **Clone dentro do Linux (`~`), e não numa pasta do Windows
> (`/mnt/c/...`).** O `cd ~` da primeira linha existe para isso. O Docker
> fica muito mais lento quando lê arquivos que estão no disco do Windows, e
> os finais de linha podem quebrar os scripts.

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
> de 3 GB, e o `spark-sql` e o `dbt` pedem mais enquanto rodam. Por padrão o
> WSL2 pode usar até metade da memória do computador: numa máquina com 8 GB
> fica apertado. Feche o que não estiver usando (navegador com muitas abas,
> por exemplo).

---

## Dicas para o dia a dia no Windows

**Colar no terminal.** No terminal do Ubuntu, cole com `Ctrl+Shift+V` ou com
o **botão direito do mouse** (`Ctrl+V` nem sempre funciona). Se aparecer um
aviso sobre "colar várias linhas", confirme em **Colar mesmo assim**.

**Vários terminais.** A trilha pede mais de um terminal: um dentro de um
container (`docker exec -it spark bash`) e outro no Ubuntu, para o
`make conferir`. Abra outra janela do Ubuntu pelo menu Iniciar e entre na
pasta com `cd ~/jornada_dados`.

**Abrir as telas no navegador do Windows.** `http://localhost:9000` (MinIO)
e `http://localhost:8080` (Airflow) abrem direto: o WSL2 repassa as portas.

**Ver os arquivos do repositório no Windows.** No terminal do Ubuntu, dentro
da pasta do repositório, `explorer.exe .` abre a pasta no Explorador de
Arquivos.

**Ao fim da sessão.** `make parar` para os serviços e **mantém** o seu
progresso. Na próxima: abra o Docker Desktop (se usa a opção A), o terminal
do Ubuntu, `cd ~/jornada_dados` e `make subir`.

---

## 🆘 Problemas comuns no Windows

| O que apareceu | O que é | O que fazer |
|---|---|---|
| `make: command not found` | Faltou o passo 3, ou você está no PowerShell | No terminal do **Ubuntu**: `sudo apt install make` |
| `Cannot connect to the Docker daemon` | Docker Desktop fechado (opção A) ou serviço parado (opção B) | Abra o Docker Desktop, ou `sudo systemctl start docker` |
| `The command 'docker' could not be found in this WSL 2 distro` | A integração do Docker Desktop com o Ubuntu está desligada | Passo 2, opção A, item 4 |
| `permission denied while trying to connect to the Docker daemon` | Sessão anterior ao `usermod` (opção B) | `wsl --shutdown` no PowerShell e abra o Ubuntu de novo |
| `port is already allocated` no `make subir` | Outro programa usa uma das portas da trilha | Veja as [portas no README](../README.md#-pré-requisitos-checklist-rápido) e pare o programa que ocupa a porta |
| `bash\r: No such file or directory` ao rodar um `make` | O repositório foi clonado numa pasta do Windows | Clone de novo dentro do Linux (passo 4) |
| Tudo muito lento | Repositório em `/mnt/c/...`, ou pouca memória | Passo 4 e a nota de memória do passo 5 |

Veja também o [FAQ](./faq.md).
