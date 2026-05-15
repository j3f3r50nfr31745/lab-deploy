#!/bin/bash

copiar_arquivos() {

    sshpass -p "$SENHA" scp \
    -o StrictHostKeyChecking=no \
    -r ../modulos ../core \
    $USUARIO@$IP:/tmp/lab/
}
