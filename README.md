# README - pods

## 1. Prepare 

### 1.a. Prepare directory structure and environment

Create `secrets` folder for storing several sensitive data, and `logs` folder for application logs:

    make prepare-dirs

Copy `.env.example` to `.env`. Edit according to your environment.

### 1.b. Prepare secrets

Prepare the following files into `secrets` folder:

   * `secrets/web/server.pem`: A single PEM-encoded file containing the private key and the certificate for the web server. Note that the domain name of `MARKETPLACE_URL` (specified inside `.env` must be the same as the CN of the certificate).
   * `secrets/mangopay-client-password`: client password for MangoPay HTTP API 
   * `secrets/postgres/postgres-password`: password for PostgreSQL superuser
   * `secrets/postgres/opertusmundi-password`: password for PostgreSQL normal user `opertusmundi` who owns all databases
   * `secrets/camunda/admin-password`: admin password for Camunda BPM server (used for both UI-based administration and REST API)
   * `secrets/mailer/mail-password`: password for the SMTP server (see also `MAIL_*` environment variables inside `.env`)
   * `secrets/jupyterhub-access-token`: access token for the administrator of JupyterHub (or an empty file if no JupyterHub is present)
  
Generate keys: an HMAC key for signing cookies and JWT tokens, and an RSA key for signing contracts. You must pass as an argument the distinguished name (DNAME) of the signing party: 

    make generate-signing-keys CONTRACT_SIGNPDF_DNAME='CN=example.com,OU=devel,O=Example Domain,L=Athens,ST=Greece,C=GR'

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

Setup Elasticsearch indices and transformations (once):

    make elasticsearch-setup

Bring BPM engine/worker up:

    docker-compose up -d bpm_engine 
    docker-compose up -d bpm_worker 

Bring catalogue up:

    docker-compose up -d catalogueapi 

Bring profiling service up:
    
    docker-compose up -d profile

Bring persistent-identifier service (PID) up:

    docker-compose up -d pid

Bring mailing service up:

    docker-compose up -d mailer

Bring api-gateway service up:

    docker-compose up -d api_gateway
 
Bring the web frontend up (at 0.0.0.0:8443):

    docker-compose up -d web

The web frontend will be accessible at `https://<SERVER_NAME>:8443`, where `<SERVER_NAME>` is the name (Common-Name, CN) specified at server's certificate (at `./secrets/web/server.pem`)  
