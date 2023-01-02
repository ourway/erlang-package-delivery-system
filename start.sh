#!/bin/sh

if [ -z $DELIVERY_CONFIG_DIR ]; then
	DELIVERY_CONFIG_DIR="./etc"
fi

CONFIG=""

for i in $(ls $DELIVERY_CONFIG_DIR/*.config); do
  CONFIG="$CONFIG -config $i"
done

echo "$CONFIG"

erl -pa ebin -pa lib/*/ebin $CONFIG -args_file $DELIVERY_CONFIG_DIR/vm.args
