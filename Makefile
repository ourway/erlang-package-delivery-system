run:
	@rebar3 shell --sname dev_2@localhost

build:
	@rm -rf _build
	@rebar3 deps get
	@rebar3 deps upgrade
	@rebar3 compile
	@rebar3 dialyzer
	@rebar3 fmt
