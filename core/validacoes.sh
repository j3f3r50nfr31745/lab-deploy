#!/bin/bash

validar_root() {

    if [ "$EUID" -ne 0 ]; then

        echo
        echo "[ERRO] Execute como root."
        echo

        exit 1
    fi
}

# =========================================================
# DEPENDÊNCIAS
# =========================================================

validar_dependencias() {

    titulo "VALIDANDO DEPENDÊNCIAS"

    # =========================================================
    # SSHPASS
    # =========================================================

    if command -v sshpass >/dev/null 2>&1; then

        status_ok "sshpass instalado"

    else

        status_warn "sshpass não instalado"

        apt update >/dev/null 2>&1 &

        spinner $!

        status_ok "Atualizando repositórios"

        apt install sshpass -y >/dev/null 2>&1 &

        spinner $!

        if command -v sshpass >/dev/null 2>&1; then

            status_ok "sshpass instalado com sucesso"

        else

            status_erro "Falha ao instalar sshpass"

            pausa

            exit 1
        fi
    fi

    echo
}