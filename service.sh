#!/bin/bash

if [[ $1 == 'start' ]]
then
        echo 'starting iri...'
        docker-compose -p iri up -d
elif [[ $1 == 'stop' ]]
then
        echo 'stoppping iri...'
        docker-compose -p iri stop
elif [[ $1 == 'restart' ]]
then
        echo 'restarting iri...'
        docker-compose -p iri restart
elif [[ $1 == 'reinit' ]]
then
        echo 'reinitialising iri...'
	docker-compose -p iri stop
        docker-compose -p iri rm -f
        docker-compose -p iri up -d
elif [[ $1 == 'destroy' ]]
then
        echo 'destroying iri containers...'
        docker-compose -p iri rm -f
else
        echo 'commands: <start,stop,restart,reinit,destroy>'
fi

