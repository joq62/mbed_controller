%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(controller). 

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").

%% --------------------------------------------------------------------
-define(SERVER,?MODULE).


%% External exports
-export([
	 get_spec/2,
	 actual_state/0,
	 load_read_specs/0,
	
	 read_state/0,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
	
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================
%%---------------------------------------------------------------
%% Function: get_spec(Name,Vsn)
%% @doc: retreive Service info        
%% @param: Name,Vsn
%% @returns:[SeviceSpecInfo]|{error,eexists}
%%
%%---------------------------------------------------------------
-spec get_spec(string(),string())->  [term()]|{atom(),list()}.
get_spec(Name,Vsn)->
    gen_server:call(?SERVER, {get_spec,Name,Vsn},infinity).

%%---------------------------------------------------------------
%% Function: actual_state()
%% @doc: evaluta Id and Vms to start and delete        
%% @param: non
%% @returns:[{Id,ToStart,ToDelete}]
%%
%%---------------------------------------------------------------
-spec actual_state()-> [term()].
actual_state()->
    gen_server:call(?SERVER, {actual_state},infinity).

%%---------------------------------------------------------------
%% Function: load_read_specs()
%% @doc: git load and read service_specs files        
%% @param: non
%% @returns:[ServiceSpecsInfo]|{error,Reason}
%%
%%---------------------------------------------------------------
-spec load_read_specs()-> [term()]|{atom(),term()}.
load_read_specs()->
    gen_server:call(?SERVER, {load_read_specs},infinity).

%%---------------------------------------------------------------
%% Function:template()
%% @doc: service spec template  list of {app,vsn} to run      
%% @param: 
%% @returns:[{app,vsn}]
%%
%%---------------------------------------------------------------
%-spec template()-> [{atom(),string()}].
%template()->
 %   gen_server:call(?SERVER, {template},infinity).


%% ====================================================================
%% Support functions
%% ====================================================================
%%---------------------------------------------------------------
%% Function:read_state()
%% @doc: read theServer State variable      
%% @param: non 
%% @returns:State
%%
%%---------------------------------------------------------------
-spec read_state()-> term().
read_state()->
    gen_server:call(?SERVER, {read_state},infinity).
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

%% ====================================================================
%% Gen Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    
%    spawn(fun()->do_desired_state() end),
%    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{}
    }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_call({get_spec,Name,Vsn},_From, State) ->
    Reply=lib_controller:get_spec(Name,Vsn,State),
    {reply, Reply, State};

handle_call({actual_state},_From, State) ->
    Reply=lib_controller:actual_state(State),
    {reply, Reply, State};

handle_call({read_state},_From, State) ->
    Reply=State,
    {reply, Reply, State};
handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};

handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_cast(Msg, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched info",[Info])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

		  
