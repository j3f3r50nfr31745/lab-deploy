#!/bin/bash

source ../core/logger.sh
source ../core/config.conf

configurar_dns() {

    titulo "MÓDULO DNS"

    DNSNONE_OK="NAO"
    DNS_CONFIGURADO="NAO"
    RESOLV_IMUTAVEL="NAO"
    RESOLV_FISICO="NAO"
    RESOLVED_DESATIVADO="NAO"

    linha

    # =========================================================
    # VERIFICA DNS=NONE
    # =========================================================

    if grep -q "^dns=none" "$ARQ_NM"; then

        status_ok "Verificando dns=none"

        DNSNONE_OK="SIM"

    else

        status_warn "Verificando dns=none"

    fi

    echo

    # =========================================================
    # VERIFICA RESOLV.CONF
    # =========================================================

    if grep -q "$DNS1" /etc/resolv.conf 2>/dev/null && \
       grep -q "$DNS2" /etc/resolv.conf 2>/dev/null && \
       grep -q "$DNS3" /etc/resolv.conf 2>/dev/null && \
       [ ! -L /etc/resolv.conf ]; then

        status_ok "Verificando resolv.conf"

        DNS_CONFIGURADO="SIM"

    else

        status_warn "Verificando resolv.conf"

    fi

    # =========================================================
    # VERIFICA DNS1
    # =========================================================

    if grep -q "$DNS1" /etc/resolv.conf 2>/dev/null; then

        status_ok "Verificando DNS1 ($DNS1)"

    else

        status_warn "Verificando DNS1 ($DNS1)"

    fi

    # =========================================================
    # VERIFICA DNS2
    # =========================================================

    if grep -q "$DNS2" /etc/resolv.conf 2>/dev/null; then

        status_ok "Verificando DNS2 ($DNS2)"

    else

        status_warn "Verificando DNS2 ($DNS2)"

    fi

    # =========================================================
    # VERIFICA DNS3
    # =========================================================

    if grep -q "$DNS3" /etc/resolv.conf 2>/dev/null; then

        status_ok "Verificando DNS3 ($DNS3)"

    else

        status_warn "Verificando DNS3 ($DNS3)"

    fi

    # =========================================================
    # VERIFICA IMUTABILIDADE
    # =========================================================

    if lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then

        status_ok "Verificando proteção resolv.conf"

        RESOLV_IMUTAVEL="SIM"

    else

        status_warn "Verificando proteção resolv.conf"

    fi

    # =========================================================
    # VERIFICA LINK SIMBÓLICO
    # =========================================================

    if [ ! -L /etc/resolv.conf ]; then

        status_ok "Verificando tipo resolv.conf"

        RESOLV_FISICO="SIM"

    else

        status_warn "Verificando tipo resolv.conf"

    fi

    echo

    # =========================================================
    # VERIFICA SYSTEMD-RESOLVED
    # =========================================================

    if systemctl is-enabled systemd-resolved >/dev/null 2>&1; then

        status_warn "Verificando systemd-resolved"

    else

        status_ok "Verificando systemd-resolved"

        RESOLVED_DESATIVADO="SIM"

    fi

    echo

    linha

    titulo "RESUMO"

    if [ "$DNSNONE_OK" = "SIM" ]; then

        status_ok "dns=none"

    else

        status_warn "dns=none"

    fi

    if [ "$DNS_CONFIGURADO" = "SIM" ]; then

        status_ok "DNS configurado"

    else

        status_warn "DNS configurado"

    fi

    if [ "$RESOLV_IMUTAVEL" = "SIM" ]; then

        status_ok "resolv.conf protegido"

    else

        status_warn "resolv.conf protegido"

    fi

    if [ "$RESOLVED_DESATIVADO" = "SIM" ]; then

        status_ok "systemd-resolved"

    else

        status_warn "systemd-resolved"

    fi

    echo

    linha

    menu "1 - Aplicar configurações DNS"
    menu "2 - Reverter alterações"
    menu "0 - Voltar"

    echo

    read -p "Escolha: " OPCAO < /dev/tty

    case $OPCAO in

    # =========================================================
    # APLICAR
    # =========================================================

    1)

        linha

        status_ok "Aplicando configurações DNS"

        progresso 30

        cp "$ARQ_NM" "${ARQ_NM}.bak" 2>/dev/null

        chattr -i /etc/resolv.conf 2>/dev/null

        if ! grep -q "^dns=none" "$ARQ_NM"; then

            sed -i '/^\[main\]/a dns=none' "$ARQ_NM"

            status_ok "Configurando dns=none"

        else

            status_ok "dns=none já configurado"

        fi

        rm -f /etc/resolv.conf

        cat > /etc/resolv.conf <<EOF
nameserver $DNS1
nameserver $DNS2
nameserver $DNS3
EOF

        chmod 644 /etc/resolv.conf

        status_ok "Criando resolv.conf"

        systemctl disable systemd-resolved >/dev/null 2>&1
        systemctl stop systemd-resolved >/dev/null 2>&1

        status_ok "Desativando systemd-resolved"

        systemctl restart NetworkManager >/dev/null 2>&1 &

        spinner $!

        status_ok "Reiniciando NetworkManager"

        echo

        read -p "Deseja proteger o resolv.conf? (S/N): " RESP < /dev/tty

        if [[ "$RESP" =~ ^[Ss]$ ]]; then

            chattr +i /etc/resolv.conf

            status_ok "Protegendo resolv.conf"

        else

            status_warn "resolv.conf mantido mutável"

        fi

        ;;

    # =========================================================
    # REVERTER
    # =========================================================

    2)

        linha

        status_ok "Revertendo alterações"

        progresso 20

        # REMOVE IMUTABILIDADE
        chattr -i /etc/resolv.conf 2>/dev/null
        chattr -i /run/systemd/resolve/stub-resolv.conf 2>/dev/null

        status_ok "Desprotegendo resolv.conf"

        # REMOVE DNS=NONE
        sed -i '/^dns=none$/d' "$ARQ_NM"

        status_ok "Removendo dns=none"

        # REMOVE RESOLV.CONF
        rm -f /etc/resolv.conf

        # RESTAURA LINK SIMBÓLICO
        ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

        chmod 644 /etc/resolv.conf

        status_ok "Restaurando link simbólico"

        # REATIVA SYSTEMD-RESOLVED
        systemctl enable systemd-resolved >/dev/null 2>&1
        systemctl start systemd-resolved >/dev/null 2>&1

        status_ok "Reativando systemd-resolved"

        # REINICIA NETWORKMANAGER
        systemctl restart NetworkManager >/dev/null 2>&1 &

        spinner $!

        status_ok "Reiniciando NetworkManager"

        ;;

    0)

        return
        ;;

    *)

        status_warn "Opção inválida"

        ;;

    esac

    echo

    linha

    titulo "STATUS FINAL"

    if [ ! -L /etc/resolv.conf ]; then

        status_ok "resolv.conf está como ARQUIVO físico"

    else

        status_warn "resolv.conf está como LINK simbólico"

    fi

    echo

    if grep -q "$DNS1" /etc/resolv.conf 2>/dev/null && \
       grep -q "$DNS2" /etc/resolv.conf 2>/dev/null && \
       grep -q "$DNS3" /etc/resolv.conf 2>/dev/null; then

        status_ok "DNS atualmente configurados"

    else

        status_warn "DNS atualmente configurados"

    fi

    grep nameserver /etc/resolv.conf 2>/dev/null

    echo

    pausa
}