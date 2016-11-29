export GOPATH=~
go get github.com/jwfriese/iossimulator
go build script/test.go
carthage update --platform 'iOS'
./test "iOS 10.0" "iPhone 6"
