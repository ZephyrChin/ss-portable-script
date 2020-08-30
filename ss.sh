#!/bin/bash
URL=""
PORT="10000"
PASSWD="000000"
INSTALL_PATH="/root"

download_bin(){
wget -P ${PATH} ${URL}
local bin_name=`ls ${PATH}|grep .gz`
gzip -d ${PATH}/${bin_name}
mv ${PATH}/${bin_name} ${PATH}/ss
chmod +x ${PATH}/ss
}

set_start_script(){
cat > ${PATH}/auto.sh << EOF
#!/bin/bash
${PATH}/ss -s 'ss://AEAD_CHACHA20_POLY1305:${PASSWD}@:${PORT}' -verbose
EOF
chmod +x ${PATH}/auto.sh
}

set_service(){
cat > /etc/systemd/system/ss.service << EOF
[Unit]
Description=Keep Alive
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/run/shadowsocks.pid
ExecStart=${PATH}/auto.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

echo "---download---"
download_bin
echo "---set start script---"
set_start_script
echo "---set service---"
set_service
systemctl enable ss
systemctl restart ss
