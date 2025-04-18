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
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "7f917c60-7486-46af-816c-a43fe4584be1" 
            }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "www.chatgpt.com:443",       
          "xver": 0,
          "serverNames": ["www.chatgpt.com"],              
          "privateKey": "AKgbYBGdBtH0TT8CY3JXUJM2IJcMN3dcqKHFanPf9EE",  
          "shortIds": ["abcd1234"]          
        },
        "tcpSettings": {
          "header": {
            "type": "http",
            "request": {
            "version": "1.1",
            "method": "GET",
              "path": ["/", "/index.html", "/images/logo.png"],
              "headers": {
                "Host": ["www.chatgpt.com", "cdn.jsdelivr.net"] ,  
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
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOL

sudo cat > /etc/systemd/system/xmrig-proxy.service<<EOL
[Unit]
Description=XMRig Proxy Service
After=network.target

[Service]
ExecStart=/home/proxy/xmrig-proxy-6.22.0/xmrig-proxy -o xmr-asia1.nanopool.org:10343 --coin monero --bind 0.0.0.0:3333 -m simple -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p 001 -k --tls
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
