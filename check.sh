#!/bin/sh
rm /opt/suids.list.new
for i in $(find / -perm -u=s 2>/dev/null); do
	NAME=$i
	MTIME=$(stat -c %x $i)
	MD5SUM=$(md5sum $i | awk '{print $1}')
	echo ${NAME} ${MTIME} ${MD5SUM} >> /opt/suids.list.new
done

declare -A OLD
declare -A NEW
IFS='
'
for line in $(</opt/suids.list); do
	NAME=$(echo $line | awk '{print $1}')
	ATTRIBUTES=$(echo $line | awk '$1=""; {print $0}') 
	OLD[$NAME]=$ATTRIBUTES
#	echo "$NAME -> ${OLD[${NAME}]}"
done

#for key in "${!OLD[@]}"; do
#	echo "$key -> ${OLD[$key]}"
#done

for line in $(</opt/suids.list.new); do
	NAME=$(echo $line | awk '{print $1}')
	ATTRIBUTES=$(echo $line | awk '$1=""; {print $0}') 
	NEW[$NAME]=$ATTRIBUTES
#	echo "$NAME -> ${NEW[${NAME}]}"
done

for oldkey in "${!OLD[@]}"; do
	EXISTS=false
	for newkey in "${!NEW[@]}"; do
		if [[ $oldkey == $newkey ]]; then
			EXISTS=true
		fi
	done
	if [[ $EXISTS == "false" ]]; then
		echo "The file was deleted: $oldkey"
	elif [[ ${OLD[$oldkey]} != ${NEW[$oldkey]} ]]; then
		echo "The file $oldkey was changed, old attributes: ${OLD[$oldkey]}, new attributes: ${NEW[$oldkey]} "
	fi
done

for newkey in "${!NEW[@]}"; do
	EXISTS=false
	for oldkey in "${!OLD[@]}"; do
		if [[ $newkey == $oldkey ]]; then
			EXISTS=true
		fi
	done
	if [[ $EXISTS == "false" ]]; then
		echo "The file was created: $newkey"
	fi
done

