import os
import subprocess

NGINX_SITES_DIR = '/etc/nginx/conf.d'
APACHE_SITES_DIR = '/usr/local/apache2/htdocs'


def add_site(domain_name, site_directory):
    nginx_conf = f"""
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

    # Docker exec command to write nginx conf
    command = f'docker exec -i nginx sh -c "echo \'{nginx_conf}\' > {NGINX_SITES_DIR}/{domain_name}.conf"'
    subprocess.run(command, shell=True, check=True)

    # Docker exec command to create apache document root
    command = f'docker exec -i apache mkdir -p {site_directory}'
    subprocess.run(command, shell=True, check=True)

    print(f"{domain_name} has been added with document root: {site_directory}")


if __name__ == "__main__":
    domain = input("Enter the domain name: ")
    document_root = os.path.join(APACHE_SITES_DIR, domain)
    add_site(domain, document_root)
