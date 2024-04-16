#! /usr/bin/bash

getopts ":cdr" option

    case $option in
        (c)
            docker compose up -d
            ;;
        (d)
            docker compose down -v --rmi all
            ;;
        (r)
            docker compose down -v --rmi all
            docker compose up -d
            ;;
        (?)
            echo "no match"
            ;;
    esac
