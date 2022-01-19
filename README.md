# README - pods

## 1. Prepare 

### 1.a. Prepare directory structure and environment

Create `secrets` folder for storing several sensitive data, and `logs` folder for application logs:

    mkdir -p secrets/{postgres,camunda,catalogueapi,flyway}
    mkdir -p logs/{catalogueapi,api-gateway,bpm-engine,bpm-worker,profile,pid}

Copy `.env.example` to `.env`. Edit according to your environment.

### 1.b. Prepare secrets

Prepare the following files into `secrets`:

   * `secrets/mangopay-client-password`: client password for MangoPay HTTP API 
   * `secrets/postgres/postgres-password`: password for PostgreSQL superuser
   * `secrets/postgres/opertusmundi-password`: password for PostgreSQL normal user `opertusmundi` who owns all databases
   * `secrets/camunda/admin-password`: admin password for Camunda BPM server (used for both UI-based administration and REST API)

Generate a secret key for catalogueapi Flask server:

    dd if=/dev/urandom bs=1 count=12 | base64 -w 0 > secrets/catalogueapi/secret_key    

Generate a JWT secret:

    dd if=/dev/urandom bs=1 count=60 | base64 -w 0 > secrets/jwt-secret

Generate configuration for the security-sensitive part of Flyway:

    cat secrets/postgres/opertusmundi-password | xargs printf "flyway.password=%s" > secrets/flyway/secret.conf

## 2. Setup

Bring database up (all needed databases will be created on the first time):

    docker-compose up -d postgres

Apply database migrations (up to current version of `cli` submodule) for `opertusmundi` database:

    docker-compose run --rm flyway migrate

Bring BPM engine/worker up:

    docker-compose up -d bpm_engine 
    docker-compose up -d bpm_worker 

__Todo__
