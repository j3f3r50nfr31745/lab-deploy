# scripts/install.sh

```bash
#!/bin/bash

REPO_URL="https://github.com/j3f3r50nfr31745/lab-deploy.git"
INSTALL_DIR="/opt/lab-deploy"

clear

echo "============================================================"
echo " LAB DEPLOY - INSTALADOR AUTOMÁTICO"
echo "============================================================"

echo

echo "[INFO] Verificando privilégios..."

if [ "$EUID" -ne 0 ]; then

    echo
    echo "Execute como root ou sudo."
    echo

    exit 1
fi

echo

echo "[OK] Instalando dependências"

apt update -y >/dev/null 2>&1
apt install -y git curl sshpass >/dev/null 2>&1

echo

echo "[OK] Removendo estrutura antiga"

rm -rf "$INSTALL_DIR"

echo

echo "[OK] Clonando repositório"

git clone "$REPO_URL" "$INSTALL_DIR"

if [ $? -ne 0 ]; then

    echo
    echo "[ERRO] Falha ao baixar repositório"
    echo

    exit 1
fi

echo

echo "[OK] Ajustando permissões"

chmod +x "$INSTALL_DIR"/core/*.sh
chmod +x "$INSTALL_DIR"/modulos/*.sh
chmod +x "$INSTALL_DIR"/scripts/*.sh

echo

echo "[OK] Criando launcher"

cat > /usr/local/bin/lab-deploy << 'EOF'
#!/bin/bash
cd /opt/lab-deploy/core
sudo ./menu.sh
EOF

chmod +x /usr/local/bin/lab-deploy

echo

echo "============================================================"
echo " INSTALAÇÃO FINALIZADA"
echo "============================================================"

echo

echo "Execute utilizando:"
echo

echo "sudo lab-deploy"
echo
```

# Como subir o instalador

Após criar o arquivo:

```bash
cd ~/lab

git add .
git commit -m "Adicionado instalador bootstrap"
git push
```

# Como testar em outra máquina

```bash
curl -s https://raw.githubusercontent.com/j3f3r50nfr31745/lab-deploy/main/scripts/install.sh | sudo bash
```

