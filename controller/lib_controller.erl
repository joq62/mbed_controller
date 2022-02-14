%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_controller).   
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
-include("configs.hrl").
-include_lib("kernel/include/logger.hrl").
%%---------------------------------------------------------------------
%% Records for test


%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 restart/1,
	 start_appl/0,
	 connect_nodes/0
	
	]).


%% ====================================================================
%% External functions
%% ====================================================================
start_appl()->
    MyNode=node(),
  %  {ok,HostName}=net:gethostname(),
    {ok,AllInfo}=rpc:call(node(),appl_mgr,get_all_appl_info,[],5000),

    Z=[{App,Vsn,MyNode,rpc:call(node(),appl_mgr,get_info,[App,Vsn,constraints],5000)}||{{App,Vsn},_}<-AllInfo],
    io:format("HostName,constraints ~p~n",[{Z,?FUNCTION_NAME,?MODULE,?LINE}]),

    L1=[{App,Vsn}||{{App,Vsn},_}<-AllInfo,
		   lists:member({host,MyNode},rpc:call(node(),appl_mgr,get_info,[App,Vsn,constraints],5000))],
%		   lists:member({host,HostName},rpc:call(node(),appl_mgr,get_info,[App,Vsn,constraints],5000))],
     			
    L2=[{App,Vsn}||{{App,Vsn},_}<-AllInfo,
		   []=:=rpc:call(node(),appl_mgr,get_info,[App,Vsn,constraints],5000)],
    ApplToStart=lists:append(L1,L2),
    start_appl(ApplToStart).
		  



start_appl(ApplToStart)->
    start_appl(ApplToStart,[]).
start_appl([],StartRes)->
    StartRes;
start_appl([{App,Vsn}|T],Acc)->

   {ok,ApplVm}=rpc:call(node(),loader,create,[],5000),
    Res=case rpc:call(node(),loader,load_appl,[App,Vsn,ApplVm],5000) of
	    {error,Reason}->
		{error,Reason};
	    ok->
		case rpc:call(node(),loader,start_appl,[App,ApplVm],5000) of
		    {error,Reason}->
			{error,Reason};
		    ok->
			{ok,App,Vsn}
		end
	end,
    
    start_appl(T,[Res|Acc]).

  
		      
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
restart(Type)->
%    io:format("application:stop(loader) ~p~n",[{application:stop(loader),
%						?HostNodesFile,?FUNCTION_NAME,?MODULE,?LINE}]),
%    io:format("application:unload(loader) ~p~n",[{application:unload(loader),
%					    ?HostNodesFile,?FUNCTION_NAME,?MODULE,?LINE}]),
    io:format("  boot_loader:start([Type]), ~p~n",[{boot_loader:start([Type]),
						?HostNodesFile,?FUNCTION_NAME,?MODULE,?LINE}]),
   % application:stop(loader),
   % application:unload(loader),
   % boot_loader:start([Type]),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
connect_nodes()->
 
    io:format("HostNodesFile ~p~n",[{?HostNodesFile,?FUNCTION_NAME,?MODULE,?LINE}]),
    
    {ok,ContactNodes}=file:consult(?HostNodesFile),
    Res=[{N,net_adm:ping(N)}||N<-ContactNodes],
    Res.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

		   
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------




