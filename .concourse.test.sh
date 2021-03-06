#!/bin/bash

set -e -x

export GOPATH=~
go get -u github.com/jwfriese/iossimulator
ls $GOPATH/src/github.com/jwfriese/iossimulator
go build script/test.go
carthage update --platform 'iOS'
./test "iOS 10.0" "iPhone 6" "false"
