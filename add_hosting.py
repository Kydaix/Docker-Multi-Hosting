# add_hosting.py
import os
import sys


def create_nginx_conf(domain):
    conf = f"""
    server {{
        listen 80;
        server_name {domain};

        location / {{
            proxy_pass http://apache:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }}
    }}
    """

    with open(f'./nginx/conf.d/{domain}.conf', 'w') as file:
        file.write(conf)

    print(f"Nginx configuration for {domain} created.")


def create_apache_directory(domain):
    path = f"./apache_data/{domain}"
    os.makedirs(path, exist_ok=True)
    print(f"Directory for {domain} created at {path}.")


def main():
    if len(sys.argv) != 2:
        print("Usage: python add_hosting.py <domain>")
        sys.exit(1)

    domain = sys.argv[1]
    create_nginx_conf(domain)
    create_apache_directory(domain)
    print("Reload Nginx and Apache containers to apply changes.")


if __name__ == "__main__":
    main()
