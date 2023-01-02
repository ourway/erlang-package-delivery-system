Delivery System
===============

A package delivery platform

Requirements
-----------
```console
    $ brew install erlang rebar3
```

Please make sure `erts-*` path is updated in `rebar.config` file before compiling.

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
