# README - pods

## 1. Prepare 

### 1.a. Prepare directory structure and environment

Create `secrets` folder for storing several sensitive data, and `logs` folder for application logs:

    mkdir -p secrets
    mkdir -p logs/{catalogueapi,api-gateway,bpm-engine,bpm-worker}

Copy `.env.example` to `.env`. Edit according to your environment.

### 1.b. Prepare secrets

Create a `secrets` directory with the following structure:

```
secrets/
├── catalogueapi
│   └── secret_key             # secret key for catalogueapi Flask server 

```

A JWT secret can be generated:

    dd if=/dev/urandom bs=1 count=60 | base64 -w 0 > secrets/jwt-secret

## 2. Setup


__Todo__
