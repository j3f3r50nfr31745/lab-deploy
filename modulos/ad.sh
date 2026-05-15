#!/bin/bash

ingressar_ad() {

    echo
    echo "[AD] Inserção no domínio"
    echo

    while true
    do

        read -p "Digite o domínio: " DOMINIO < /dev/tty
        read -p "Digite o usuário do domínio: " USUARIO < /dev/tty
        read -s -p "Digite a senha do domínio: " SENHA < /dev/tty

        echo
        echo

        echo "========================================="
        echo " DADOS INFORMADOS "
        echo "========================================="
        echo "DOMÍNIO : ${DOMINIO^^}"
        echo "USUÁRIO : $USUARIO"
        echo "SENHA   : $SENHA"
        echo "========================================="
        echo

        read -p "Os dados estão corretos? (S/N): " CONFIRMA < /dev/tty

        if [[ "$CONFIRMA" =~ ^[Ss]$ ]]; then
            break
        fi

        echo
        echo "Redigitando informações..."
        echo

    done

    echo
    echo "Executando comando:"
    echo
    echo "cid join domain=\"${DOMINIO^^}\" user=\"$USUARIO\" pass=\"$SENHA\""
    echo

    cid join domain="${DOMINIO^^}" user="$USUARIO" pass="$SENHA"

    if [ $? -eq 0 ]; then

        echo
        echo "Computador inserido no domínio com sucesso."

    else

        echo
        echo "Falha ao inserir no domínio."

    fi
}
