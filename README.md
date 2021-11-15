Delivery System
===============

A package delivery platform

Build
-----
```console
	$ make build
	$ make
```

Usage
-----
```erl
Packages = packages:batch(100).
reciever:recieve_packages(Packages).
```
