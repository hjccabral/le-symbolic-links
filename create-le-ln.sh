#!/bin/bash

# Solicita o nome do site
read -p "Qual site seria a criação dos symbolic links? " site

# Define o diretório de arquivos
dir_archive="/etc/letsencrypt/archive/$site"
dir_live="/etc/letsencrypt/live/$site"

# Função para encontrar o maior número em um nome de arquivo
maior_numero() {
    local arquivos=("$@")
    local maior=0
    for arquivo in "${arquivos[@]}"; do
        # Extrai o número do nome do arquivo usando expressão regular
        if [[ "$arquivo" =~ [0-9]+ ]]; then
            numero="${BASH_REMATCH[0]}"
            if [[ "$numero" -gt "$maior" ]]; then
                maior="$numero"
            fi
        fi
    done
    echo "$maior"
}

# Encontra os arquivos mais recentes em cada tipo
chain_mais_novo=$(ls "$dir_archive" | grep -Eo "chain[0-9]+$*" | sort -V | tail -n 1)
fullchain_mais_novo=$(ls "$dir_archive" | grep -Eo "fullchain[0-9]+$*" | sort -V | tail -n 1)
privkey_mais_novo=$(ls "$dir_archive" | grep -Eo "privkey[0-9]+$*" | sort -V | tail -n 1)
cert_mais_novo=$(ls "$dir_archive" | grep -Eo "cert[0-9]+$*" | sort -V | tail -n 1)

# Obtém o maior número entre todos os arquivos
ultimo_valor=$(maior_numero "$chain_mais_novo" "$fullchain_mais_novo" "$privkey_mais_novo" "$cert_mais_novo")

# Cria os links simbólicos
ln -sf "$dir_archive/privkey$ultimo_valor.pem" "$dir_live/privkey.pem"
ln -sf "$dir_archive/fullchain$ultimo_valor.pem" "$dir_live/fullchain.pem"
ln -sf "$dir_archive/cert$ultimo_valor.pem" "$dir_live/cert.pem"
ln -sf "$dir_archive/chain$ultimo_valor.pem" "$dir_live/chain.pem"

echo "Links simbólicos criados com sucesso!"
