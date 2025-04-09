#!/bin/bash

set -e

echo "✅ Adding PostgreSQL 17 YUM repo..."
cat <<EOF | sudo tee /etc/yum.repos.d/pgdg.repo
[pgdg17]
name=PostgreSQL 17 for RHEL 9 - x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-9-x86_64
enabled=1
gpgcheck=0
EOF

echo "✅ Installing PostgreSQL 17 server..."
sudo dnf install -y postgresql17 postgresql17-server

echo "✅ Creating data directory..."
sudo mkdir -p /var/lib/pgsql/17/data
sudo chown postgres:postgres /var/lib/pgsql/17/data

echo "✅ Initializing the database..."
sudo -u postgres /usr/bin/initdb -D /var/lib/pgsql/17/data

echo "✅ Creating systemd service unit..."
sudo tee /etc/systemd/system/postgresql-17.service > /dev/null <<EOF
[Unit]
Description=PostgreSQL 17 database server
After=network.target

[Service]
Type=forking
User=postgres
Group=postgres

ExecStart=/usr/bin/pg_ctl start -D /var/lib/pgsql/17/data -s -l /var/lib/pgsql/17/logfile -o "-p 5432"
ExecStop=/usr/bin/pg_ctl stop -D /var/lib/pgsql/17/data -s -m fast
ExecReload=/usr/bin/pg_ctl reload -D /var/lib/pgsql/17/data -s

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Fixing log file permissions..."
sudo touch /var/lib/pgsql/17/logfile
sudo chown postgres:postgres /var/lib/pgsql/17/logfile

echo "✅ Reloading systemd and starting PostgreSQL 17..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now postgresql-17

echo "✅ PostgreSQL 17 setup completed!"
sudo systemctl status postgresql-17 --no-pager
