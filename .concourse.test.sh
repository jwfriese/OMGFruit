export GOPATH=/usr/local/go
go get github.com/jwfriese/iossimulator
go build script/test.go
./test "iOS 10.0" "iPhone 6"
