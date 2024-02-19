# Very simple terraform and ansible setup

Running `terraform apply` will deploy one xsmall droplet on digital ocean and then it will setup test fastapi app:
1. provide xsmall droplet on digitalocean
2. add ssh key
3. run ansible script
    - create appuser user&group
    - setup fastapi app
    - setup nginx
    - setup gunicorn as systemd service

The terraform command will output the ip address of where the app is available.