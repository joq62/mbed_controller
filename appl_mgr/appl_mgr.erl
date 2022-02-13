%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(appl_mgr). 

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("configs.hrl").
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------
-define(SERVER,?MODULE).


%% External exports
-export([
	 get_info/3,
	 get_all_appl_info/0,
	 get_appl_dir/1,
	 get_appl_dir/2,
	 load_specs/0,

	 read_state/0,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		appl_info
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
%% Vm machine functions
%% ====================================================================

%%---------------------------------------------------------------
%% Function:get_info(App,Vsn,Type)
%% @doc: resturns value appfile related to App,Vsn and type      
%% @param: Application,Vsn and Type
%% @returns:{ok,Value}|{error,[eexists,App,Vsn]}|{error,[undefined, App,Vsn,Type]}
%%
%%---------------------------------------------------------------
-spec get_info(atom(),string(),atom())-> {term()}|{atom(),term()}.
get_info(App,Vsn,Type)->
    gen_server:call(?SERVER,{get_info,App,Vsn,Type},infinity).

%%---------------------------------------------------------------
%% Function:get_all_appl_info()
%% @doc:returns the path to ebin for latest version ofapplication App      
%% @param: Application 
%% @returns:{ok,Path}|{error,[eexists,App]}|{error,[appl_specs_not_loaded]}
%%
%%---------------------------------------------------------------
-spec get_all_appl_info()-> {term()}|{atom(),term()}.
get_all_appl_info()->
    gen_server:call(?SERVER,{get_all_appl_info},infinity).
%%---------------------------------------------------------------
%% Function:get_appl_dir(App)
%% @doc:returns the path to ebin for latest version ofapplication App      
%% @param: Application 
%% @returns:{ok,Path}|{error,[eexists,App]}|{error,[appl_specs_not_loaded]}
%%
%%---------------------------------------------------------------
-spec get_appl_dir(atom())-> {atom(),string()}|{atom(),term()}.
get_appl_dir(App)->
    gen_server:call(?SERVER,{get_appl_dir,App},infinity).
%%---------------------------------------------------------------
%% Function:get_appl_dir(App,Vsn)
%% @doc:returns the path to ebin for application App with vsn Vsn      
%% @param: Application, Version
%% @returns:{ok,Path}|{error,[eexists,App,Vsn]}|{error,[appl_specs_not_loaded]}
%%
%%---------------------------------------------------------------
-spec get_appl_dir(atom(),string())-> {atom(),string()}|{atom(),term()}.
get_appl_dir(App,Vsn)->
    gen_server:call(?SERVER,{get_appl_dir,App,Vsn},infinity).


%%---------------------------------------------------------------
%% Function:load_specs()
%% @doc:Down load application specs from git_hub.It will replace existing      
%% @param: non
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
-spec load_specs()-> {atom(),node()}|{atom(),term()}.
load_specs()->
    gen_server:call(?SERVER,{load_specs},infinity).
%%---------------------------------------------------------------
%% Function:update_specs()
%% @doc:Not implemented Adding removing appl_specs in existing appl_specs  dir on the node      
%% @param: non
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
%-spec update_specs()-> {atom(),node()}|{atom(),term()}.
%update_specs()->
 %   gen_server:call(?SERVER,{update_specs},infinity).

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

    ok=case rpc:call(node(),lib_appl_mgr,load_specs,[],30*1000) of 
	{error,_}->
	    ApplInfoList=undefined;
	{ok,ApplInfoList}->
	    ok
    end,
    
%    spawn(fun()->do_desired_state() end),
%    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{appl_info=ApplInfoList}
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
handle_call({get_info,App,Vsn,Type},_From, State) ->
    
    Reply=case lists:keyfind({App,Vsn},1,State#state.appl_info) of
	      false->
		  {error,[eexists,App,Vsn]};
	      AppInfo->
		  rpc:call(node(),lib_appl_mgr,get_info,[Type,AppInfo],5000)
	  end,
    {reply, Reply, State};


handle_call({get_all_appl_info},_From, State) ->
    Reply=case State#state.appl_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  {ok,AppInfoList}
	  end,
    {reply, Reply, State};

handle_call({load_specs},_From, State) ->
    Reply=case rpc:call(node(),lib_appl_mgr,load_specs,[],5000) of 
	      {error,Reason}->
		  NewState=State,
		  {error,Reason};
	      {ok,ApplInfo}->
		  NewState=State#state{appl_info=ApplInfo},
		  ok
	  end,
    {reply, Reply, NewState};

handle_call({get_appl_dir,App},_From, State) ->
    Reply=case State#state.appl_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  rpc:call(node(),lib_appl_mgr,get_appl_dir,[App,latest,AppInfoList],5000)
	  end,
    {reply, Reply, State};

handle_call({get_appl_dir,App,Vsn},_From, State) ->
    Reply=case State#state.appl_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  rpc:call(node(),lib_appl_mgr,get_appl_dir,[App,Vsn,AppInfoList],5000)
	  end,
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
