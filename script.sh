#!/bin/bash

entrada=$1

saida=$2

if [ $# -ne 2 ]; then
    echo "Precisa de dois argumentos."
    echo "Exemplo : $0 /dir_entrada /dir_saida"
    exit 255
fi



if [ ! -d "$entrada" ]; then
    echo "Primeiro argumento não é um diretório." ; exit 1
elif [ ! -d "$saida" ]; then
    echo "Segundo argumento não é um diretório." ; exit 2
fi


arquivo_texto=/tmp/arquivo.txt

oldIFS=$IFS
IFS=$'\n'

comando=$(find $entrada -iregex ".*\.\(mkv\|mp4\|avi\|webm\)$" | sort)

for arquivo in $comando; do

    echo $arquivo > $arquivo_texto

    extensao=$(sed -r "s|^.*(\.[[:alnum:]]{2,4})$|\1|" $arquivo_texto)
    nome=$(basename $arquivo $extensao)

    ffmpeg -i "$arquivo" \
    -map_metadata -1 -c:v libx264 -c:a aac -r 30 \
    "$saida/$nome.mp4" > /dev/null 2>&1

done


IFS=$oldIFS

echo -e "\n\nAcabou a conversão de vídeos."
rm $arquivo_texto
