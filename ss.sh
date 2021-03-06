#!/bin/bash
URL=""
PORT="10000"
PASSWD="000000"
INSTALL_PATH="/root"

download_bin(){
wget -P ${INSTALL_PATH} ${URL}
local bin_name=`ls ${INSTALL_PATH}|grep .gz`
gzip -d ${INSTALL_PATH}/${bin_name}
mv ${INSTALL_PATH}/${bin_name%.*} ${INSTALL_PATH}/ss
chmod +x ${INSTALL_PATH}/ss
}

set_start_script(){
cat > ${INSTALL_PATH}/auto.sh << EOF
#!/bin/bash
${INSTALL_PATH}/ss -s 'ss://AEAD_CHACHA20_POLY1305:${PASSWD}@:${PORT}' -verbose
EOF
chmod +x ${INSTALL_PATH}/auto.sh
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
ExecStart=${INSTALL_PATH}/auto.sh
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
systemctl daemon-reload
systemctl enable ss
systemctl restart ss
