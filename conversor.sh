#!/bin/bash

entrada=$1 ; saida=$2

# Verifica se foi passado dois argumentos.

if [ $# -ne 2 ]; then
	echo "Precisa de dois argumentos."
	echo "Exemplo : $0 /dir_entrada /dir_saida"
	echo "Argumentos : $*, Total : $#"
	exit 255
fi


# Verifica se os argumentos são válidos.
if [ ! -d "$entrada" ]; then
	echo "Primeiro argumento não é um diretório." ; exit 1
elif [ ! -d "$saida" ]; then
	echo "Segundo argumento não é um diretório." ; exit 2
fi

# Instala o ffmpeg caso não esteja instalado.
teste1=$(dpkg --get-selections | tr -s "\t" | cut -f1 | grep "^ffmpeg$")
[ ! $teste1 ] && apt install -y ffmpeg > /dev/null 2>&1

teste2=$(dpkg --get-selections | tr -s "\t" | cut -f1 | grep "^ffmpeg$")
if [ ! $teste2 ]; then
	echo "Programa ffmpeg não foi instalado." ; exit 32
fi

# Função para criar a pastas com os logs.
pasta="/var/log/conversor/"
[ ! -d $pasta ] && mkdir $pasta


# Cria arquivos de logs.
datalog=$(date +%d-%m-%Y)
horalog=$(date +%H-%M-%S)
arquivo_log="/var/log/conversor/arquivo_$datalog@$horalog.log"
[ ! -f $arquivo_log ] && touch $arquivo_log


# Cria um arquivo temporário.
arquivo_texto=/tmp/arquivo.txt

# Pega os arquivos mkv, mp4, avi e webm, da pasta de entrada, e armazena.
comando=$(find "$entrada" -iregex ".*\.\(mkv\|mp4\|avi\|webm\)$" | sort)

oldIFS=$IFS
IFS=$'\n'
for arquivo in $comando; do
	# pega cada arquivo e colocar em um arquivo temporário.
    echo $arquivo > $arquivo_texto

    extensao=$(sed -r "s|^.*(\.[[:alnum:]]{2,4})$|\1|" $arquivo_texto)
    nome=$(basename $arquivo $extensao)

	# Converte o vídeo.
    ffmpeg -i "$arquivo" \
    -map_metadata -1 -c:v libx264 -c:a aac -r 30 \
    "$saida/$nome.mp4"

	# Salva arquivo convertido no log.
	hora_atual=$(date +%H:%M:%S)
	echo "$arquivo | $hora_atual" >> $arquivo_log

done

IFS=$oldIFS

echo -e "\n\nAcabou a conversão de vídeos."
rm $arquivo_texto




