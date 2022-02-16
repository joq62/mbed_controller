%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(fun_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

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
    ok=application:start(sd),
    io:format(" host@c200 ~p~n",[{net_adm:ping(host@c200),?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format(" host@c203 ~p~n",[{net_adm:ping(host@c203),?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format(" sd:all()  ~p~n",[{sd:all() ,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    
    ok.
 %  io:format("application:which ~p~n",[{application:which_applications(),?FUNCTION_NAME,?MODULE,?LINE}]),

