-module(simple_cache_expirer_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link(Arg) ->
    supervisor:start_link(simple_cache_expirer_sup, [Arg]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init(Arg) ->
    {ok, { {one_for_one, 500000, 1}, [
				  {simple_cache_expirer_id,
				   {simple_cache_expirer, start_link,[Arg]},
				   permanent,
				   infinity,
				   worker,
				   [simple_cache_expirer]
				  }
				 ]} }.


terminate(Reason, _S) ->
    io:format("simple_cache_expirer_sup terminating because of ~p!~n", [Reason]).
