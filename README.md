# Hébergement Partagé avec Docker

## Description
Ce projet met en place un environnement d'hébergement partagé avec Docker en utilisant un reverse-proxy Nginx, plusieurs containers Apache pour l'hébergement sécurisé des sites et un accès FTP pour chaque site.

## Prérequis
- Docker
- Docker Compose

## Installation

1. Cloner le dépôt :
    ```bash
    git clone <votre-repo-url>
    cd shared-hosting
    ```

2. Construire et démarrer les services :
    ```bash
    docker-compose up --build -d
    ```

## Ajouter un site

Pour ajouter un nouveau site, exécutez le script `create_site.sh` :
```bash
cd scripts
./create_site.sh <nom_du_site>
```

## Accès FTP

Chaque site disposera d'un accès FTP dans le répertoire `/home/vsftpd/<nom_du_site>`.

## Notes
Les fichiers de site sont situés dans le répertoire `./sites` sur la machine hôte.