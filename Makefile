.EXPORT_ALL_VARIABLES:

run: 
	@ERL_FLAGS=" -args_file ./etc/vm.args"  rebar3 shell

build:
	@rm -rf _build
	@rm rebar.lock
	@rebar3 deps get
	@rebar3 deps upgrade
	@rebar3 compile
	@rebar3 fmt
	
check:
	@rebar3 dialyzer
