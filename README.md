# API de Carrinho de Compras

## 🛠 Tech Stack

- **Ruby:** 3.3.1
- **Rails:** 7.1.3.2
- **Banco de Dados:** PostgreSQL 16
- **Jobs em Background:** Sidekiq 7
- **Agendamento de Jobs:** Sidekiq-Scheduler
- **Banco de Dados Chave-Valor:** Redis 7
- **Containerização:** Docker & Docker Compose

---

## 📦 Pré-requisitos

Para rodar este projeto, você precisará ter instalado em sua máquina:

- Docker
- Docker Compose

---

## 🚀 Como Executar a Aplicação

O projeto é totalmente containerizado, facilitando a configuração e execução do ambiente.

### 1. Construir as Imagens Docker
```bash
docker-compose build
```

### 2. Preparar o Banco de Dados

Este comando irá criar os bancos de dados de desenvolvimento e de teste, além de rodar as migrations necessárias:

```bash
docker-compose run --rm web rails db:prepare
```

### 3. Iniciar todos os Serviços

Suba todos os serviços (servidor web, Sidekiq, Postgres e Redis) em background:

```bash
docker-compose up -d
```

A API estará acessível em:
👉 [http://localhost:3000](http://localhost:3000)

---

## ✅ Como Executar os Testes

A suíte de testes foi construída com **RSpec** e cobre todas as funcionalidades da API, além de testes unitários para **models, services, serializers e jobs**.

Para rodar todos os testes:

```bash
docker-compose run --rm test
```

Esse comando utilizará o serviço `test` definido no `docker-compose.yml`, que executa `bundle exec rspec` em um ambiente de teste isolado.

---

## 🔗 API Endpoints

| Verbo      | Rota                | Descrição                                                                   |
| ---------- | ------------------- | --------------------------------------------------------------------------- |
| **GET**    | `/cart`             | Retorna o carrinho atual da sessão. Cria um novo carrinho se não existir.   |
| **POST**   | `/cart`             | Adiciona o primeiro produto ao carrinho, criando-o se necessário.           |
| **POST**   | `/cart/add_item`    | Adiciona um produto ou atualiza a quantidade se ele já existir no carrinho. |
| **DELETE** | `/cart/:product_id` | Remove um produto específico do carrinho.                                   |

---

## ⚙️ Jobs em Background

A aplicação utiliza **Sidekiq** para gerenciar tarefas assíncronas, com agendamento configurado via **sidekiq-scheduler**.

### 🔸 Marcar Carrinhos como Abandonados

**Job:** `Cart::MarkAsAbandonedJob`

* **O que faz:** Encontra carrinhos com mais de 3 horas de inatividade e os marca como `abandoned: true`.
* **Agendamento Padrão:** A cada 3 horas (`0 */3 * * *`).

### 🔸 Deletar Carrinhos Antigos

**Job:** `Cart::DeleteOldAbandonedCartsJob`

* **O que faz:** Encontra carrinhos que foram marcados como abandonados há mais de 7 dias e os remove do banco de dados.
* **Agendamento Padrão:** Diariamente, às 4 da manhã (`0 4 * * *`).
