#!/bin/bash

# =========================================================
# SOURCES
# =========================================================

source ./config.conf
source ./logger.sh
source ./validacoes.sh
source ./remoto.sh

source ../modulos/dns.sh
source ../modulos/cid.sh
source ../modulos/ad.sh
source ../modulos/hostname.sh

# =========================================================
# VALIDAÇÕES
# =========================================================

validar_root
validar_dependencias

# =========================================================
# LOOP PRINCIPAL
# =========================================================

while true
do

    printf "\033c"

    titulo "LAB DEPLOY - GERENCIAMENTO"

    echo

    menu "1 - EXECUÇÃO LOCAL"
    menu "2 - EXECUÇÃO REMOTA"
    menu "0 - SAIR"

    echo

    read -p "Selecione uma opção: " TIPO < /dev/tty

    case $TIPO in

    # =====================================================
    # EXECUÇÃO LOCAL
    # =====================================================

    1)

        while true
        do

            printf "\033c"

            titulo "EXECUÇÃO LOCAL"

            echo

            menu "1 - MÓDULO DNS"
            menu "2 - MÓDULO CID"
            menu "3 - MÓDULO AD"
            menu "4 - MÓDULO HOSTNAME"
            menu "0 - VOLTAR"

            echo

            read -p "Selecione o módulo: " MODULO < /dev/tty

            case $MODULO in

            # =================================================
            # DNS
            # =================================================

            1)

                configurar_dns
                ;;

            # =================================================
            # CID
            # =================================================

            2)

                configurar_cid
                ;;

            # =================================================
            # AD
            # =================================================

            3)

                ingressar_ad
                ;;

            # =================================================
            # HOSTNAME
            # =================================================

            4)

                configurar_hostname
                ;;

            # =================================================
            # VOLTAR
            # =================================================

            0)

                break
                ;;

            # =================================================
            # INVÁLIDO
            # =================================================

            *)

                echo

                status_warn "Opção inválida"

                sleep 2
                ;;

            esac

        done
        ;;

    # =====================================================
    # EXECUÇÃO REMOTA
    # =====================================================

    2)

        executar_remoto
        ;;

    # =====================================================
    # SAIR
    # =====================================================

    0)

        echo

        status_ok "Finalizando sistema"

        echo

        exit 0
        ;;

    # =====================================================
    # INVÁLIDO
    # =====================================================

    *)

        echo

        status_warn "Opção inválida"

        sleep 2
        ;;

    esac

done