#!/usr/bin/env bash

ARGO_AUTH=eyJhIjoiZDkyYjM0MjNiZTI5OTNhMTM3OThjMTYxMDBhMTE4YjEiLCJ0IjoiZTNlODE5NDMtNWE4Yi00MjNhLTg3ODAtMTk2OTQwOTlmOGJlIiwicyI6Ik5UUXlOamcxTnpNdE4yUTBZaTAwT0RkaExUaG1Zakl0TXpjd09HUTBaamRpTkRkbCJ9
ARGO_DOMAIN=glitch.gufengv2ss.buzz
SSH_DOMAIN=

# 下载并运行 Argo
check_file() {
  [ ! -e cloudflared ] && wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x cloudflared
}

run() {
  if [[ -n "${ARGO_AUTH}" && -n "${ARGO_DOMAIN}" ]]; then
    if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
      echo "$ARGO_AUTH" | sed 's@{@{"@g;s@[,:]@"\0"@g;s@}@"}@g' > tunnel.json
      cat > tunnel.yml << EOF
tunnel: $(sed "s@.*TunnelID:\(.*\)}@\1@g" <<< "$ARGO_AUTH")
credentials-file: /app/tunnel.json
protocol: http2

ingress:
  - hostname: $ARGO_DOMAIN
    service: http://localhost:8080
EOF
      [ -n "${SSH_DOMAIN}" ] && cat >> tunnel.yml << EOF
  - hostname: $SSH_DOMAIN
    service: http://localhost:2222
EOF
    [ -n "${FTP_DOMAIN}" ] && cat >> tunnel.yml << EOF
  - hostname: $FTP_DOMAIN
    service: http://localhost:3333
EOF
      cat >> tunnel.yml << EOF
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
      nohup ./cloudflared tunnel --edge-ip-version auto --config tunnel.yml run 2>/dev/null 2>&1 &
    elif [[ "$ARGO_AUTH" =~ ^[A-Z0-9a-z=]{120,250}$ ]]; then
      nohup ./cloudflared tunnel --edge-ip-version auto --protocol http2 run --token eyJhIjoiZDkyYjM0MjNiZTI5OTNhMTM3OThjMTYxMDBhMTE4YjEiLCJ0IjoiZTNlODE5NDMtNWE4Yi00MjNhLTg3ODAtMTk2OTQwOTlmOGJlIiwicyI6Ik5UUXlOamcxTnpNdE4yUTBZaTAwT0RkaExUaG1Zakl0TXpjd09HUTBaamRpTkRkbCJ9 2>/dev/null 2>&1 &
    fi
  else
    nohup ./cloudflared tunnel --edge-ip-version auto --protocol http2 --no-autoupdate --url http://localhost:8080 2>/dev/null 2>&1 &
    sleep 5
    local LOCALHOST=$(ss -nltp | grep '"cloudflared"' | awk '{print $4}')
    ARGO_DOMAIN=$(wget -qO- http://$LOCALHOST/quicktunnel | cut -d\" -f4)
  fi
}

export_list() {
  VMESS="{ \"v\": \"2\", \"ps\": \"Argo-Vmess\", \"add\": \"icook.hk\", \"port\": \"443\", \"id\": \"e0b94984-800b-4c0d-9124-c5ad63e8aadc\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/argo-vmess?ed=2048\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"
  cat > list << EOF
*******************************************
V2-rayN:
----------------------------
vless://e0b94984-800b-4c0d-9124-c5ad63e8aadc@icook.hk:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2Fargo-vless?ed=2048#Argo-Vless
----------------------------
vmess://$(echo $VMESS | base64 -w0)
----------------------------
trojan://e0b94984-800b-4c0d-9124-c5ad63e8aadc@icook.hk:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2Fargo-trojan?ed=2048#Argo-Trojan
----------------------------
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTplMGI5NDk4NC04MDBiLTRjMGQtOTEyNC1jNWFkNjNlOGFhZGNAaWNvb2suaGs6NDQzCg==@icook.hk:443#Argo-Shadowsocks
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS ， 伪装域名: ${ARGO_DOMAIN} ，路径: /argo-shadowsocks?ed=2048 ， 传输层安全: tls ， sni: ${ARGO_DOMAIN}
*******************************************
小火箭:
----------------------------
vless://e0b94984-800b-4c0d-9124-c5ad63e8aadc@icook.hk:443?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/argo-vless?ed=2048&sni=${ARGO_DOMAIN}#Argo-Vless
----------------------------
vmess://bm9uZTplMGI5NDk4NC04MDBiLTRjMGQtOTEyNC1jNWFkNjNlOGFhZGNAaWNvb2suaGs6NDQzCg==?remarks=Argo-Vmess&obfsParam=${ARGO_DOMAIN}&path=/argo-vmess?ed=2048&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0
----------------------------
trojan://e0b94984-800b-4c0d-9124-c5ad63e8aadc@icook.hk:443?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/argo-trojan?ed=2048#Argo-Trojan
----------------------------
ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTplMGI5NDk4NC04MDBiLTRjMGQtOTEyNC1jNWFkNjNlOGFhZGNAaWNvb2suaGs6NDQzCg==?obfs=wss&obfsParam=${ARGO_DOMAIN}&path=/argo-shadowsocks?ed=2048#Argo-Shadowsocks
*******************************************
Clash:
----------------------------
- {name: Argo-Vless, type: vless, server: icook.hk, port: 443, uuid: e0b94984-800b-4c0d-9124-c5ad63e8aadc, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: /argo-vless?ed=2048, headers: { Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: Argo-Vmess, type: vmess, server: icook.hk, port: 443, uuid: e0b94984-800b-4c0d-9124-c5ad63e8aadc, alterId: 0, cipher: none, tls: true, skip-cert-verify: true, network: ws, ws-opts: {path: /argo-vmess?ed=2048, headers: {Host: ${ARGO_DOMAIN}}}, udp: true}
----------------------------
- {name: Argo-Trojan, type: trojan, server: icook.hk, port: 443, password: e0b94984-800b-4c0d-9124-c5ad63e8aadc, udp: true, tls: true, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: { path: /argo-trojan?ed=2048, headers: { Host: ${ARGO_DOMAIN} } } }
----------------------------
- {name: Argo-Shadowsocks, type: ss, server: icook.hk, port: 443, cipher: chacha20-ietf-poly1305, password: e0b94984-800b-4c0d-9124-c5ad63e8aadc, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: /argo-shadowsocks?ed=2048, tls: true, skip-cert-verify: false, mux: false } }
*******************************************
EOF
  cat list
}

check_file
run
export_list
