%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(prototype_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start test1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=test1(),
    io:format("~p~n",[{"Stop  test1()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start test2()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=test2(),
    io:format("~p~n",[{"Stop  test2()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start test3()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=test3(),
    io:format("~p~n",[{"Stop  test3()",?MODULE,?FUNCTION_NAME,?LINE}]),


%    io:format("~p~n",[{"Start start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=start_script(),
%    io:format("~p~n",[{"Stop  start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),

   
 %   
      %% End application tests
  %  io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
  %  io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.
 %  io:format("application:which ~p~n",[{application:which_applications(),?FUNCTION_NAME,?MODULE,?LINE}]),

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
test1()->
    [Vm1|_]=test_nodes:get_nodes(),
    rpc:call(Vm1,logger,log,[info,"info1"],5000),
    rpc:call(Vm1,logger,log,[error,"error1"],5000),
    ?LOG_EMERGENCY(#{name=>"joq62"}),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
-define(Log(Vm,Level,What,Result,Reason),log(Vm,Level,?MODULE,?FUNCTION_NAME,?LINE,What,Result,Reason,node(),pid_to_list(self()))).
test2()->
    
    
    [Vm1|_]=test_nodes:get_nodes(),
    ok=log(Vm1,alert,?MODULE,?FUNCTION_NAME,?LINE,"what 1","error 1","reason 1",node(),pid_to_list(self())),
    ok=?Log(Vm1,critical,"what 2","error 2","reason 2"),

    rpc:cast(Vm1,erlang,apply,[m,f,[]]),

  %  rpc:call(Vm1,logger,log,[alert,#{when=>xx,level=>alert, }],5000),
   % rpc:call(Vm1,logger,log,[error,"error1"],5000),
   
    ok.

log(Vm,Level,Module,Function,Line,What,Result,Reason,Node,User)->
    
    Id=integer_to_list(os:system_time(microsecond),36),
   % Level1=atom_to_list(Level),
    Module1=atom_to_list(Module),
    Function1=atom_to_list(Function),
    Line1=integer_to_list(Line),
    
    Node1=atom_to_list(Node),
  %  Msg=#{id=>Id,node=>Node1,at=>Module1++":"++Function1++":"++Line1,what=>What,result=>Result,reason=>Reason,user=>User},
    Msg=#{id=>Id,node=>Node1,where=>Module1++":"++Function1++"/"++Line1,what=>What,result=>Result,reason=>Reason,user=>User},
   
    rpc:call(Vm,logger,log,[Level,Msg],5000),
    ok.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
test3()->
    timer:sleep(2000),
    {ok,Bin}=file:read_file("logs/error.1"),       
    L1=string:tokens(binary_to_list(Bin),"\n"),
    %gl=io:format("L1 ~p~n",[{L1,?MODULE,?FUNCTION_NAME,?LINE}]),
    L2=[[string:sub_string(Str,1,32),string:sub_string(Str,34,1000)]||Str<-L1],
   % gl=io:format("L2 ~p~n",[{L2,?MODULE,?FUNCTION_NAME,?LINE}]),
    L3=[[Time,string:tokens(LevelInfo,":")]||[Time,LevelInfo]<-L2],
    io:format("L3 ~p~n",[{L3,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    L4=filter1(L3,[]),
    io:format("L4 ~p~n",[{L4,?MODULE,?FUNCTION_NAME,?LINE}]),
    Error= [[{time,T},{level,"error"},{info,Info}]||[{time,T},{level,"error"},{info,Info}]<-L4],
    io:format("error ~p~n",[{Error,?MODULE,?FUNCTION_NAME,?LINE}]),

    Critical= [[{time,T},{level,"critical"},{info,Info}]||[{time,T},{level,"critical"},{info,Info}]<-L4],
    io:format("Critical ~p~n",[{Critical,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    
    ok.

filter1([],R)->
    R;    
filter1([[Time,LevelInfo]|T],Acc) ->
    [Level|Info]=LevelInfo,
    filter1(T,[[{time,Time},{level,Level},{info,Info}]|Acc]).
    


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    % suppor debugging
    ok=application:start(sd),

    % Simulate host
    ok=test_nodes:start_nodes(),
    [Vm1|_]=test_nodes:get_nodes(),

    Ebin="ebin",
    true=rpc:call(Vm1,code,add_path,[Ebin],5000),
 
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
