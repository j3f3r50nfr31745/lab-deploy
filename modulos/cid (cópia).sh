# cid.sh
#!/bin/bash

source ../core/logger.sh
source ../core/config.conf

configurar_cid() {

    titulo "MÓDULO CID"

    REPO_OK="NAO"
    CID_OK="NAO"
    DOMINIO_OK="NAO"

    linha

    # =========================================================
    # REPOSITÓRIO
    # =========================================================

    if grep -Ri "emoraes25/cid" /etc/apt/ >/dev/null 2>&1; then

        status_ok "Verificando repositório CID"

        REPO_OK="SIM"

    else

        status_warn "Verificando repositório CID"

    fi

    # =========================================================
    # PACOTES CID
    # =========================================================

    if dpkg -l | grep -q "cid-gtk" && dpkg -l | grep -q "^ii  cid"; then

        status_ok "Verificando instalação CID"

        CID_OK="SIM"

    else

        status_warn "Verificando instalação CID"

    fi

    # =========================================================
    # STATUS DOMÍNIO
    # =========================================================

    if realm list 2>/dev/null | grep -qi "domain-name"; then

        status_ok "Verificando domínio"

        DOMINIO_OK="SIM"

    else

        status_warn "Verificando domínio"

    fi

    echo

    linha

    titulo "RESUMO"

    # =========================================================
    # RESUMO REPOSITÓRIO
    # =========================================================

    if [ "$REPO_OK" = "SIM" ]; then

        status_ok "Repositório configurado"

    else

        status_warn "Repositório configurado"

    fi

    # =========================================================
    # RESUMO CID
    # =========================================================

    if [ "$CID_OK" = "SIM" ]; then

        status_ok "CID instalado"

    else

        status_warn "CID instalado"

    fi

    # =========================================================
    # RESUMO DOMÍNIO
    # =========================================================

    if [ "$DOMINIO_OK" = "SIM" ]; then

        status_ok "Computador no domínio"

    else

        status_warn "Computador no domínio"

    fi

    echo

    linha

    menu "1 - Instalar e configurar CID"
    menu "2 - Inserir computador no domínio"
    menu "3 - Reinstalar pacotes CID"
    menu "0 - Voltar"

    echo

    read -p "Escolha: " OPCAO < /dev/tty

    case $OPCAO in

    # =========================================================
    # INSTALAÇÃO COMPLETA
    # =========================================================

    1)

        linha

        status_ok "Instalando e configurando CID"

        progresso 30

        # =========================================================
        # REPOSITÓRIO
        # =========================================================

        if [ "$REPO_OK" = "NAO" ]; then

            add-apt-repository -y ppa:emoraes25/cid >/dev/null 2>&1

            status_ok "Adicionando repositório"

        else

            status_ok "Repositório já configurado"

        fi

        # =========================================================
        # UPDATE
        # =========================================================

        apt update >/dev/null 2>&1 &

        spinner $!

        status_ok "Atualizando repositórios"

        # =========================================================
        # INSTALAÇÃO
        # =========================================================

        apt install cid cid-gtk -y >/dev/null 2>&1 &

        spinner $!

        status_ok "Instalando CID"

        ;;

    # =========================================================
    # INSERÇÃO NO DOMÍNIO
    # =========================================================

    2)

        linha

        read -p "Digite o domínio: " DOMINIO < /dev/tty
        read -p "Digite o usuário: " USUARIO < /dev/tty
        read -s -p "Digite a senha: " SENHA < /dev/tty

        echo
        echo

        linha

        titulo "CONFIRMAÇÃO"

        echo "Domínio : ${DOMINIO^^}"
        echo "Usuário : $USUARIO"
        echo "Senha   : ********"

        echo

        read -p "Confirmar inserção no domínio? (S/N): " CONFIRMA < /dev/tty

        if [[ "$CONFIRMA" =~ ^[Ss]$ ]]; then

            cid join domain=${DOMINIO^^} user="$USUARIO" pass="$SENHA" >/dev/null 2>&1 &

            spinner $!

            if realm list 2>/dev/null | grep -qi "domain-name"; then

                status_ok "Computador inserido no domínio"

            else

                status_erro "Falha ao inserir no domínio"

            fi

        else

            status_warn "Inserção no domínio cancelada"

        fi

        ;;

    # =========================================================
    # REINSTALAÇÃO
    # =========================================================

    3)

        linha

        status_ok "Reinstalando pacotes CID"

        progresso 20

        apt remove cid cid-gtk -y >/dev/null 2>&1 &

        spinner $!

        status_ok "Removendo CID"

        apt install cid cid-gtk -y >/dev/null 2>&1 &

        spinner $!

        status_ok "Instalando CID"

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

    if dpkg -l | grep -q "cid-gtk" && dpkg -l | grep -q "^ii  cid"; then

        status_ok "CID instalado"

    else

        status_warn "CID instalado"

    fi

    if realm list 2>/dev/null | grep -qi "domain-name"; then

        status_ok "Computador inserido no domínio"

        realm list 2>/dev/null | grep domain-name

    else

        status_warn "Computador inserido no domínio"

    fi

    echo

  

# Sugestões implementadas

* Verificação do repositório PPA
* Verificação dos pacotes CID e CID-GTK
* Verificação se a máquina já está no domínio
* Resumo visual padronizado
* Spinner durante apt update/install
* Confirmação antes do `cid join`
* Status final real do sistema
* Compatível com o logger visual já criado
* Estrutura preparada para expansão futura

# Próximas melhorias recomendadas

## Verificação de conectividade AD

Adicionar:

```bash
ping -c 1 DC.DOMINIO.LOCAL
```

## Verificação DNS antes do join

Validar:

```bash
nslookup dominio.local
```

## Verificação Kerberos

Adicionar:

```bash
klist
```

## Log de operações

Salvar:

* data/hora
* domínio
* usuário
* hostname
* resultado

em:

```text
/var/log/lab-manager.log
```
pausa
}