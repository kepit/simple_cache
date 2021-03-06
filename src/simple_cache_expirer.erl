%%% @doc This process will expire keys.
%%%
%%% Copyright 2013 Marcelo Gornstein &lt;marcelog@@gmail.com&gt;
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%% @end
%%% @copyright Marcelo Gornstein <marcelog@gmail.com>
%%% @author Marcelo Gornstein <marcelog@gmail.com>
%%%
-module(simple_cache_expirer).
-author('marcelog@gmail.com').

-behavior(gen_server).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Types.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(state, {}).
-type state():: #state{}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exports.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Public API.
-export([start_link/1]).

%%% gen_server behavior
-export([
  init/1, handle_info/2, handle_call/3, handle_cast/2,
  code_change/3, terminate/2
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Public API.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% @doc Starts the gen_server.
-spec start_link([term()]) -> {ok, pid()} | ignore | {error, term()}.
start_link(Args) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, Args, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gen_server API.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-spec init([term()]) -> {ok, state()}.
init([Arg]) ->
  simple_cache:flush(Arg),
  io:format("simple_cache_expirer starting~n", []),
  {ok, #state{}}.

-spec handle_cast(any(), state()) -> {noreply, state()}.
handle_cast(_Msg, State) ->
  {noreply, State}.

-spec handle_info(any(), state()) -> {noreply, state()}.
handle_info({expire, CacheName, Key}, State) ->
    simple_cache:flush(CacheName, Key),
    {noreply, State};
handle_info({update, CacheName, LifeTime, Key, UpdateFun}, State) ->
    simple_cache:force_update(CacheName, LifeTime, Key, UpdateFun),
    {noreply, State};

handle_info(_Info, State) ->
  {noreply, State}.

-spec handle_call(
  term(), {pid(), reference()}, state()
) -> {reply, term() | {invalid_request, term()}, state()}.
handle_call(Req, _From, State) ->
  lager:error("Invalid request: ~p", [Req]),
  {reply, {invalid_request, Req}, State}.

-spec terminate(atom(), state()) -> ok.
terminate(Reason, _State) ->
  io:format("simple_cache_expirer terminating because of ~p!~n", [Reason]),
  ok.

-spec code_change(string(), state(), any()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

