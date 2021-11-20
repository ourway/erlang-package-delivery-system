run:
	@rebar3 compile
	@rebar3 dialyzer
	@rebar3 shell
build:
	@rm -rf _build
	@rebar3 plugins upgrade
	@rebar3 deps get
	@rebar3 deps upgrade
	@rebar3 compile
	@rebar3 dialyzer
