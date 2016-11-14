# OMGFruit

## Setup

0) Get my dependencies:<br />
[Carthage](https://github.com/Carthage/Carthage#installing-carthage)<br />
[xcpretty](https://github.com/supermarin/xcpretty#installation)<br />
[golang](https://golang.org/doc/install)<br />

1) Clone me:
```
git clone https://github.com/jwfriese/OMGFruit
cd OMGFruit
```

2) Carthage me:
```
carthage update --platform 'iOS'
```

3) Test me:
```
go build script/test.go
./test 'iOS 10.0' 'iPhone 6'
```
