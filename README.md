# Projet d'Hébergement Partagé avec Docker

## Prérequis
- Docker
- Docker Compose

## Configuration

### Ajouter un nouveau site
1. Créez un nouveau dossier pour le site dans le répertoire `sites`.
2. Ajoutez un `Dockerfile`, un fichier de configuration Apache `site.conf` et le contenu `www/`.
3. Ajoutez la configuration du site dans `nginx/conf.d/default.conf`.

### Démarrer les services
```shell
docker-compose up -d
```

### Ajouter un site sans redémarrer Nginx
1. Ajoutez la configuration du nouveau site dans `nginx/conf.d/`.
2. Utilisez la commande suivante :
```shell
docker exec -it <nginx_container_id> nginx -s reload
```