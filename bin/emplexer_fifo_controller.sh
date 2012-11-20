#!/bin/bash

pipe=/tmp/emplexer.fifo

trap "rm -f $pipe" EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

current_dir=`pwd`


while true
do
    if read line <$pipe; then
    	echo $line

        if [[ "$line" == 'quit' ]]; then
            break
        fi 

        if [[ "$line" == 'kill' ]]; then
        	#mata plex_notify
        	kill -15 `ps ax|grep -i plex_notify|head -n 1|awk '{print $1}'`
        fi

        type=${line:0:1} #pega somente o primeiro caracter da string
        if [[ $type  == 'c' ]]; then # é cache?
        	# c|nome do arquivo|url
        	url=${line#c|*|} #pega somente a url (terceiro campo)
        	tmp=${line%|*} # pega somente o primeiro e segundo campo para facilitar o corte depois
        	file=${tmp#c|} # tira o primeiro campo do tmp para pegar nome do arquivo
			
			wget -q -O "/persistfs/plugins_archive/emplexer/emplexer_default_archive/$file" "$url"
        fi

        if [[ $type == 's' ]]; then 
        	#start plexNotify
        	#s|id do arquivo no plex|tempo do pooling|url base do plex (http://192.168.2.9:32400/)"
        	url=${line#*|*|*|} #somente o ultimo campo (url)
        	tmp=${line%|*}
        	sleepTime=${tmp#*|*|} #somente o tempo
        	tmp=${line%|*|*}
        	key=${tmp#*|} #somente a chave
        	echo "iniciando plex_notify com comando plex_notify.sh $key $sleepTime '$url' & "
        	sh $current_dir/plex_notify.sh $key $sleepTime "$url" &
        	echo `pidof plex_notify.sh`
        fi




    fi



done

echo "Reader exiting"