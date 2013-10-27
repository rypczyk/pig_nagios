#!/bin/bash

echo "Nadgrywam konfigurację..."
rsync -vr config/* /

echo "Restartuje usługi"

# TODO: Można by jakoś wykrywać, które usługi restartować po nadgraniu konfiguracji...
for D in nginx postgresql redis-server
	do
		service $D restart
done

