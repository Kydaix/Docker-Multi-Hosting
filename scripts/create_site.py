import os
import subprocess

# Chemins de configuration
nginx_sites_available = '../nginx/sites-available/'
nginx_sites_enabled = '../nginx/sites-enabled/'
apache_sites_dir = '../apache/sites/'
domain_name = input("Entrez le nom de domaine : ")
ftp_user = input("Entrez le nom de l'utilisateur FTP : ")
ftp_pass = input("Entrez le mot de passe FTP : ")

# Création des répertoires du site
site_dir = os.path.join(apache_sites_dir, domain_name)
if not os.path.exists(site_dir):
    os.makedirs(site_dir)

# Création de la configuration Apache
vhost_config = f"""
<VirtualHost *:80>
    ServerName {domain_name}
    DocumentRoot /var/www/html/{domain_name}
    <Directory /var/www/html/{domain_name}>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/{domain_name}_error.log
    CustomLog /var/log/apache2/{domain_name}_access.log combined
</VirtualHost>
"""

with open(os.path.join(nginx_sites_available, domain_name), 'w') as f:
    f.write(vhost_config)

# Création de la configuration Nginx
nginx_config = f"""
server {{
    listen 80;
    server_name {domain_name};

    location / {{
        proxy_pass http://apache:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
"""

with open(os.path.join(nginx_sites_available, domain_name), 'w') as f:
    f.write(nginx_config)

# Création d'un lien symbolique pour activer le site Nginx
os.symlink(os.path.join(nginx_sites_available, domain_name), os.path.join(nginx_sites_enabled, domain_name))

# Création de l'utilisateur FTP
subprocess.run([
    'docker-compose', 'exec', 'ftp', 'sh', '-c',
    f"echo -e \"{ftp_pass}\n{ftp_pass}\" | pure-pw useradd {ftp_user} -u ftpuser -d /home/ftpusers/{ftp_user} && pure-pw mkdb"
])

# Redémarrage des services
subprocess.run(['docker-compose', 'exec', 'nginx', 'nginx', '-s', 'reload'])
subprocess.run(['docker-compose', 'exec', 'apache', 'apachectl', 'graceful'])

print(f"Le site {domain_name} a été créé avec succès.")