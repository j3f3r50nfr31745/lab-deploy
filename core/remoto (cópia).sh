#!/bin/bash

executar_remoto() {

    printf "\033c"

    titulo "EXECUÇÃO REMOTA"

    echo

    read -p "Digite o IP destino: " IP < /dev/tty
    read -p "Digite o usuário SSH: " USUARIO < /dev/tty
    read -s -p "Digite a senha SSH: " SENHA < /dev/tty

    echo
    echo

    linha

    menu "1 - MÓDULO DNS"
    menu "2 - MÓDULO CID"
    menu "3 - MÓDULO AD"
    menu "4 - MÓDULO HOSTNAME"
    menu "0 - VOLTAR"

    echo

    read -p "Escolha o módulo remoto: " MODULO < /dev/tty

    case $MODULO in

    # =====================================================
    # DNS
    # =====================================================

    1)

        MODULO_SCRIPT="dns.sh"
        FUNCAO="configurar_dns"
        ;;

    # =====================================================
    # CID
    # =====================================================

    2)

        MODULO_SCRIPT="cid.sh"
        FUNCAO="configurar_cid"
        ;;

    # =====================================================
    # AD
    # =====================================================

    3)

        MODULO_SCRIPT="ad.sh"
        FUNCAO="ingressar_ad"
        ;;

    # =====================================================
    # HOSTNAME
    # =====================================================

    4)

        MODULO_SCRIPT="hostname.sh"
        FUNCAO="configurar_hostname"
        ;;

    # =====================================================
    # VOLTAR
    # =====================================================

    0)

        return
        ;;

    # =====================================================
    # INVÁLIDO
    # =====================================================

    *)

        status_warn "Opção inválida"

        pausa

        return
        ;;

    esac

    echo

    linha

    status_ok "Copiando estrutura LAB"

    # =====================================================
    # SCP
    # =====================================================

    sshpass -p "$SENHA" scp \
    -o StrictHostKeyChecking=no \
    -r .. ${USUARIO}@${IP}:/tmp/lab >/dev/null 2>&1

    if [ $? -ne 0 ]; then

        status_erro "Falha ao copiar arquivos"

        pausa

        return
    fi

    status_ok "Estrutura copiada"

    echo

    linha

    status_ok "Executando módulo remoto"

    # =====================================================
    # EXECUÇÃO REMOTA COM LOGGER
    # =====================================================

    sshpass -p "$SENHA" ssh \
    -o StrictHostKeyChecking=no \
    -t ${USUARIO}@${IP} \
    "echo '$SENHA' | sudo -S bash -c '
    cd /tmp/lab/core 2>/dev/null || cd /tmp/lab/lab/core
    source ./logger.sh
    source ../modulos/${MODULO_SCRIPT}
    ${FUNCAO}
    '"

    echo

    pausa
}