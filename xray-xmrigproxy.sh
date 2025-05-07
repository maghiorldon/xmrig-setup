#!/bin/bash

sudo apt install curl openssl -y

sudo apt update && sudo apt upgrade -y

sudo mkdir /home/proxy

cd /home/proxy

wget https://github.com/xmrig/xmrig-proxy/releases/download/v6.22.0/xmrig-proxy-6.22.0-linux-static-x64.tar.gz

tar xzfv xmrig-proxy-6.22.0-linux-static-x64.tar.gz

bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)

sudo cp /usr/local/etc/xray/config.json /usr/local/etc/xray/config.json.backup

sudo cat > /usr/local/etc/xray/config.json<<EOL
{ 
    "inbounds": [
      { 
            "port": 443, 
            "protocol": "shadowsocks",
            "settings": {
                   "method": "chacha20-ietf-poly1305",   
                   "password": "abc123", 
                   "network": "tcp,udp"
                                }
         }
                            ], 
       "outbounds": [
        { 
              "protocol": "freedom", 
              "settings":
                       {
                             "servers": [ 
                               { 
                                      "address": "127.0.0.1", 
                                      "port": 3333
          }
        ]
      }
    }
  ]
}
EOL

sudo cat > /etc/systemd/system/xmrig-proxy.service<<EOL
[Unit]
Description=XMRig Proxy Service
After=network.target

[Service]
ExecStart=/home/proxy/xmrig-proxy-6.22.0/xmrig-proxy -o pool.supportxmr.com:9000 --coin monero --bind 0.0.0.0:3333 -m simple -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p 001 -k --tls
WorkingDirectory=/home/proxy/xmrig-proxy-6.22.0
User=root
Group=root
Restart=always
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl stop xray.service

sudo systemctl stop xmrig-proxy.service

sudo systemctl daemon-reload

sudo systemctl reenable xray.service

sudo systemctl reenable xmrig-proxy.service

sudo systemctl start xray.service

sudo systemctl start xmrig-proxy.service
