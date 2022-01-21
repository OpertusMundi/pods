# README - pods

## 1. Prepare 

### 1.a. Prepare directory structure and environment

Create `secrets` folder for storing several sensitive data, and `logs` folder for application logs:

    make prepare-dirs

Copy `.env.example` to `.env`. Edit according to your environment.

### 1.b. Prepare secrets

Prepare the following files into `secrets` folder:

   * `secrets/mangopay-client-password`: client password for MangoPay HTTP API 
   * `secrets/postgres/postgres-password`: password for PostgreSQL superuser
   * `secrets/postgres/opertusmundi-password`: password for PostgreSQL normal user `opertusmundi` who owns all databases
   * `secrets/camunda/admin-password`: admin password for Camunda BPM server (used for both UI-based administration and REST API)
   * `secrets/mailer/mail-password`: password for the SMTP server (see also `MAIL_*` environment variables inside `.env`)

Generate a key to be used for signing cookies and JWT tokens:

    make generate-signing-key

Generate for the security-sensitive part of Flyway configuration:

    make generate-secret-for-Flyway 

### 1.c. Fix ownership of data volumes

This step is needed because data volumes (i.e. named volumes managed by Docker) are initially owned by `root`. 

    make fix-ownership-of-data-volumes

## 2. Setup

### 2.a. 

Bring PostgreSQL database up (all needed databases will be created on the first time):

    docker-compose up -d postgres

Apply database migrations (up to current version of `cli` submodule) for `opertusmundi` database:

    make database-migrate

Bring Elasticsearch up:

    docker-compose up -d elasticsearch

Setup Elasticsearch indices and transformations:

    make elastic-setup

Bring BPM engine/worker up:

    docker-compose up -d bpm_engine 
    docker-compose up -d bpm_worker 

Bring catalogue up:

    docker-compose up -d catalogueapi 

Bring profiling service up:
    
    docker-compose up -d profile

Bring persistent-identifier service (PID) up:

    docker-compose up -d pid
    
__Todo__
