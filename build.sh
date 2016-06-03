#!/usr/bin/env bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

go tool yacc -o parser.go -p "obo" parser.y
go build
