#!/usr/bin/env bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

go tool yacc -o parser.go -p "parser" parser.y
go build
