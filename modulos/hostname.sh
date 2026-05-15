#!/bin/bash

configurar_hostname() {

    printf "\033c"

    titulo "MÓDULO HOSTNAME"

    HOST_ATUAL=$(hostname)

    echo

    status_ok "Hostname atual: $HOST_ATUAL"

    echo

    linha

    read -p "Digite o nome da secretaria: " SECRETARIA < /dev/tty
    read -p "Digite o número do patrimônio: " PATRIMONIO < /dev/tty

    # =====================================================
    # NORMALIZAÇÃO
    # =====================================================

    SECRETARIA=$(echo "$SECRETARIA" | tr '[:lower:]' '[:upper:]')

    SECRETARIA=$(echo "$SECRETARIA" | \
    sed 's/ /-/g' | \
    sed 's/[^A-Z0-9-]//g')

    NOVO_HOST="${SECRETARIA}-${PATRIMONIO}"

    echo

    linha

    titulo "CONFIRMAÇÃO"

    echo
    echo "Hostname atual : $HOST_ATUAL"
    echo "Novo hostname  : $NOVO_HOST"
    echo

    read -p "Confirmar alteração? (S/N): " CONFIRMA < /dev/tty

    if [[ ! "$CONFIRMA" =~ ^[Ss]$ ]]; then

        status_warn "Alteração cancelada"

        pausa

        return
    fi

    echo

    linha

    status_ok "Alterando hostname"

    # =====================================================
    # HOSTNAMECTL
    # =====================================================

    hostnamectl set-hostname "$NOVO_HOST"

    # =====================================================
    # /etc/hostname
    # =====================================================

    echo "$NOVO_HOST" > /etc/hostname

    # =====================================================
    # /etc/hosts
    # =====================================================

    sed -i "s/^127.0.1.1.*/127.0.1.1\t$NOVO_HOST/g" /etc/hosts

    # =====================================================
    # RESTART
    # =====================================================

    systemctl restart systemd-hostnamed >/dev/null 2>&1

    echo

    linha

    titulo "STATUS FINAL"

    HOST_FINAL=$(hostname)

    if [ "$HOST_FINAL" = "$NOVO_HOST" ]; then

        status_ok "Hostname atualizado"

    else

        status_erro "Falha ao atualizar hostname"

    fi

    echo

    status_ok "Hostname atual: $HOST_FINAL"

    echo

    pausa
}
