#!/bin/bash

sudo apt update

sudo apt install curl openssl -y

sudo mkdir /home/xray

bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)

wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

tar xzfv xmrig-6.22.2-linux-static-x64.tar.gz


sudo   cat >/etc/systemd/system/xmrig1.service <<EOL
[Unit]
Description=xmrig

[Service]
WorkingDirectory=/home/ubuntu/xmrig-6.22.2
ExecStart=/home/ubuntu/xmrig-6.22.2/xmrig -o 43.201.147.64:3333 -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p x --proxy 127.0.0.1:1080 
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=xmrig
User=root

[Install]
WantedBy=multi-user.target
EOL

sudo cat > /etc/systemd/system/xray-client.service
<<EOL
[Unit]
Description=Xray Client Service
After=network.target

[Service]
ExecStart=/usr/local/bin/xray run -c /home/xray/xray-config.json
Restart=on-failure
User=youruser
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOL


sudo cat > /home/xray/xray-config.json
<<EOL
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true,
        "ip": "127.0.0.1"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "43.201.147.64",  // 替換成你的伺服器域名或 IP
            "port": 443                         // 與伺服器設定一致的端口（這裡以 443 為例）
            "users": [
              {
                "id": "7f917c60-7486-46af-816c-a43fe4584be1",   // 服務端設定的 UUID
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "www.chatgpt:443",     // 與服務端偽裝目標一致
          "xver": 0,
          "serverNames": ["www.chatgpt.com"]           // 如果服務端有設定假域名，可填入；此例中預留空陣列
          "publicKey": "vHqUMf1iUOoRmrQaAjn4eXFyLLmV1LdswiYQ2dZocBA",   //xray x25519
          "shortIds": ["abcd1234"]        // 與服務端設定一致的 shortIds
        },
   "tcpSettings": {
          "header": {
            "type": "http",
            "request": {
            "version": "1.1",
            "method": "GET",
              "path": ["/", "/index.html", "/images/logo.png"],
              "headers": {
                "Host": ["www.chatgpt.com", "cdn
jsdelivr.net"] ,  // 與 dest 或 serverNames 保持一致的主機名以達到更好的偽裝效果
                "User-Agent":  [
"Mozilla/5.0  (Windows NT 10.0; Win64; x64)   AppleWebKit/537.36  (KHTML, like Gecko)   Chrome/122.0.0.0 Safari/537.36"
 ],
                "Accept-Encoding": ["gzip, deflate"],
                "Connection": ["keep-alive"],
                "Pragma": "no-cache",
                "Cache-Control": "no-cache"
              }
            }
          }
        }
      }
    }
  ]
}
EOL

sudo systemctl stop xray

sudo systemctl stop xray-client.service

sudo systemctl stop xmrig.service

sudo systemctl daemon-reload

sudo systemctl enable xmrig.service

sudo systemctl enable xray-client.service

sudo systemctl start xray-client.service

sudo systemctl start xmrig.service
