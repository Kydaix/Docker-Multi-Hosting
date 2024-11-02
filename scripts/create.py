import os

NGINX_SITES_DIR = './nginx/sites'
APACHE_SITES_DIR = './apache/my-websites'


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
    with open(os.path.join(NGINX_SITES_DIR, f'{domain_name}.conf'), 'w') as f:
        f.write(nginx_conf)

    # Create the Apache directory structure
    if not os.path.exists(APACHE_SITES_DIR):
        os.makedirs(APACHE_SITES_DIR)

    if not os.path.exists(site_directory):
        os.makedirs(site_directory)

    print(f"{domain_name} has been added with document root: {site_directory}")


if __name__ == "__main__":
    domain = input("Enter the domain name: ")
    document_root = os.path.join(APACHE_SITES_DIR, domain)
    add_site(domain, document_root)
