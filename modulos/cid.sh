#!/bin/bash

configurar_cid() {

    printf "\033c"

    titulo "MÓDULO CID"

    echo

    # =====================================================
    # VERIFICAÇÕES
    # =====================================================

    if grep -q "multiverse" /etc/apt/sources.list 2>/dev/null; then

        status_ok "Repositório configurado"

    else

        status_warn "Repositório configurado"
    fi

    if dpkg -l | grep -q "cid"; then

        status_ok "CID instalado"

    else

        status_warn "CID instalado"
    fi

    if realm list 2>/dev/null | grep -qi "domain-name"; then

        status_ok "Computador no domínio"

    else

        status_warn "Computador no domínio"
    fi

    echo

    linha

    titulo "RESUMO"

    echo

    if grep -q "multiverse" /etc/apt/sources.list 2>/dev/null; then

        status_ok "Repositório configurado"

    else

        status_warn "Repositório configurado"
    fi

    if dpkg -l | grep -q "cid"; then

        status_ok "CID instalado"

    else

        status_warn "CID instalado"
    fi

    if realm list 2>/dev/null | grep -qi "domain-name"; then

        status_ok "Computador no domínio"

    else

        status_warn "Computador no domínio"
    fi

    echo

    linha

    menu "1 - Instalar e configurar CID"
    menu "2 - Inserir computador no domínio"
    menu "3 - Re-instalar pacotes CID"
    menu "0 - Voltar"

    echo

    read -p "Escolha: " OPCAO < /dev/tty

    case $OPCAO in

    # =====================================================
    # INSTALAR CID
    # =====================================================

    1)

        echo

        linha

        status_ok "Instalando e configurando CID"

        progresso 30

        # =================================================
        # REPOSITÓRIO
        # =================================================

        status_ok "Adicionando repositório"

        add-apt-repository multiverse -y >/dev/null 2>&1

        # =================================================
        # UPDATE
        # =================================================

        DEBIAN_FRONTEND=noninteractive apt update -y >/dev/null 2>&1

        if [ $? -eq 0 ]; then

            status_ok "Atualizando repositórios"

        else

            status_erro "Falha ao atualizar repositórios"

            pausa

            return
        fi

        # =================================================
        # INSTALAÇÃO
        # =================================================

        status_ok "Instalando pacotes CID"

        DEBIAN_FRONTEND=noninteractive apt install -y \
        cid \
        cid-gtk \
        realmd \
        sssd \
        sssd-tools \
        libnss-sss \
        libpam-sss \
        adcli \
        samba-common-bin \
        oddjob \
        oddjob-mkhomedir \
        packagekit >/dev/null 2>&1

        if [ $? -eq 0 ]; then

            status_ok "Pacotes instalados"

        else

            status_erro "Falha ao instalar pacotes"

            pausa

            return
        fi

        # =================================================
        # STATUS FINAL
        # =================================================

        echo

        linha

        titulo "STATUS FINAL"

        echo

        if dpkg -l | grep -q "cid"; then

            status_ok "CID instalado"

        else

            status_warn "CID instalado"
        fi

        echo

        pausa
        ;;

    # =====================================================
    # INGRESSO NO DOMÍNIO
    # =====================================================

    2)

        ingressar_ad
        ;;

    # =====================================================
    # REINSTALAR
    # =====================================================

    3)

        echo

        linha

        status_ok "Reinstalando pacotes CID"

        progresso 30

        DEBIAN_FRONTEND=noninteractive apt remove --purge -y cid cid-gtk >/dev/null 2>&1

        DEBIAN_FRONTEND=noninteractive apt autoremove -y >/dev/null 2>&1

        DEBIAN_FRONTEND=noninteractive apt install -y cid cid-gtk >/dev/null 2>&1

        if [ $? -eq 0 ]; then

            status_ok "CID reinstalado"

        else

            status_erro "Falha ao reinstalar CID"
        fi

        echo

        pausa
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

        sleep 2
        ;;

    esac
}