import os
import subprocess

def add_site(site_name, domain_name):
  site_path = f"sites/{site_name}"
  www_path = os.path.join(site_path, "www")
  os.makedirs(www_path, exist_ok=True)

  # Dockerfile for the new Apache site
  dockerfile_content = """
    FROM httpd:alpine
    COPY www/ /usr/local/apache2/htdocs/
    """
  with open(os.path.join(site_path, "Dockerfile"), "w") as f:
    f.write(dockerfile_content)

  # Update Nginx configuration
  nginx_config = f"""
    upstream {site_name} {{
        server {site_name}:80;
    }}

    server {{
        listen 80;
        server_name {domain_name};

        location / {{
            proxy_pass http://{site_name};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }}
    }}
    """
  with open("nginx/nginx.conf", "a") as nginx_conf:
    nginx_conf.write(nginx_config)

  # Build and start the new Apache container
  subprocess.run(["docker compose", "build", site_name], check=True)
  subprocess.run(["docker compose", "up", "-d", site_name], check=True)
  subprocess.run(["docker compose", "restart", "nginx"], check=True)

  print(f"Site {site_name} ajouté avec succès pour le domaine {domain_name}.")

# Utilisation du script
add_site("test.unislaw.fr", "test.unislaw.fr")