#!/bin/bash

executar_remoto() {

    printf "\033c"

    titulo "EXECUÇÃO REMOTA"

    # =====================================================
    # DESCOBRIR DIRETÓRIO REAL DO PROJETO
    # =====================================================

    BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

    echo

    read -p "Digite o IP destino: " IP < /dev/tty
    read -p "Digite o usuário SSH: " USUARIO < /dev/tty
    read -s -p "Digite a senha SSH: " SENHA < /dev/tty

    echo
    echo

    linha

    status_ok "Copiando estrutura LAB"

    # =====================================================
    # REMOVE ESTRUTURA ANTIGA
    # =====================================================

    sshpass -p "$SENHA" ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    ${USUARIO}@${IP} "rm -rf /tmp/lab" >/dev/null 2>&1

    # =====================================================
    # SCP
    # =====================================================

    sshpass -p "$SENHA" scp \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -r "$BASE_DIR" \
    ${USUARIO}@${IP}:/tmp/

    if [ $? -ne 0 ]; then

        status_erro "Falha ao copiar arquivos"

        echo
        echo "Verifique:"
        echo " - IP"
        echo " - Usuário"
        echo " - Senha"
        echo " - SSH habilitado"
        echo " - Firewall"
        echo

        pausa

        return
    fi

    status_ok "Estrutura copiada"

    # =====================================================
    # LOOP REMOTO
    # =====================================================

    while true
    do

        printf "\033c"

        titulo "EXECUÇÃO REMOTA - ${IP}"

        echo

        menu "1 - MÓDULO DNS"
        menu "2 - MÓDULO CID"
        menu "3 - MÓDULO AD"
        menu "4 - MÓDULO HOSTNAME"
        menu "5 - EXECUTAR TODOS"
        menu "0 - DESCONECTAR"

        echo

        read -p "Escolha o módulo remoto: " MODULO < /dev/tty

        case $MODULO in

        1)

            MODULO_SCRIPT="dns.sh"
            FUNCAO="configurar_dns"

            executar_modulo_remoto
            ;;

        2)

            MODULO_SCRIPT="cid.sh"
            FUNCAO="configurar_cid"

            executar_modulo_remoto
            ;;

        3)

            MODULO_SCRIPT="ad.sh"
            FUNCAO="ingressar_ad"

            executar_modulo_remoto
            ;;

        4)

            MODULO_SCRIPT="hostname.sh"
            FUNCAO="configurar_hostname"

            executar_modulo_remoto
            ;;

        5)

            executar_todos_remoto
            ;;

        0)

            status_ok "Desconectando sessão remota"

            sleep 1

            break
            ;;

        *)

            status_warn "Opção inválida"

            sleep 2
            ;;

        esac

    done
}

# =========================================================
# EXECUÇÃO INDIVIDUAL
# =========================================================

executar_modulo_remoto() {

    echo

    linha

    status_ok "Executando módulo remoto"

    sshpass -p "$SENHA" ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -t ${USUARIO}@${IP} \
    "echo '$SENHA' | sudo -S bash -c '

    cd /tmp/lab/core

    source ./logger.sh
    source ../modulos/${MODULO_SCRIPT}

    ${FUNCAO}

    '"

    echo

    pausa
}

# =========================================================
# EXECUÇÃO COMPLETA
# =========================================================

executar_todos_remoto() {

    echo

    linha

    titulo "EXECUÇÃO COMPLETA REMOTA"

    echo

    status_ok "Ordem de execução"

    echo " 1 - DNS"
    echo " 2 - CID"
    echo " 3 - AD"
    echo " 4 - HOSTNAME"

    echo

    read -p "Confirmar execução completa? (S/N): " CONFIRMA < /dev/tty

    if [[ ! "$CONFIRMA" =~ ^[Ss]$ ]]; then

        status_warn "Execução cancelada"

        pausa

        return
    fi

    echo

    sshpass -p "$SENHA" ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -t ${USUARIO}@${IP} \
    "echo '$SENHA' | sudo -S bash -c '

    cd /tmp/lab/core

    source ./logger.sh

    source ../modulos/dns.sh
    source ../modulos/cid.sh
    source ../modulos/ad.sh
    source ../modulos/hostname.sh

    configurar_dns
    configurar_cid
    ingressar_ad
    configurar_hostname

    '"

    echo

    status_ok "Execução completa finalizada"

    pausa
}