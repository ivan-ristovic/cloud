#!/bin/bash

if id -u somename &>/dev/null ; then
    echo "git user already created"
    exit 1
fi

set -xe;

# create git user
sudo adduser git

# allow docker exec
sudo usermod -aG docker git

# Modify the git user's shell to forward commands to the sh executable inside the container
# NOTE: `gitea` container name here is hardcoded
cat <<"EOF" | sudo tee /home/git/docker-shell
#!/bin/sh
/usr/bin/docker exec -i -u git --env SSH_ORIGINAL_COMMAND="$SSH_ORIGINAL_COMMAND" gitea sh "$@"
EOF
sudo chmod +x /home/git/docker-shell
sudo usermod -s /home/git/docker-shell git

# Redirect ssh requests to host git user to container
# NOTE: `gitea` container name here is hardcoded
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat <<"EOF" | sudo tee -a /etc/ssh/sshd_config
Match User git
  AuthorizedKeysCommandUser git
  AuthorizedKeysCommand /usr/bin/docker exec -i -u git gitea /usr/local/bin/gitea keys -c /data/gitea/conf/app.ini -e git -u %u -t %t -k %k
EOF

sudo systemctl restart ssh.service
