%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_loader).   
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
-include("configs.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%


%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 start/0,
	 do_clone_specs/1,
	 do_clone/1
	]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("controller ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    application:stop(controller),
    application:unload(controller),
    ok=do_clone(),
    ok=application:start(controller),
    ok.


do_clone_specs(Node)->
    git_clone_host_files(Node),
    git_clone_appl_files(Node),
    ok.
do_clone()->
    do_clone(node()).
do_clone(Node)->
    git_clone_host_files(Node),
    git_clone_appl_files(Node),
    git_clone_controller(Node),
    ok.

git_clone_controller(Node)->
    rpc:call(Node,os,cmd,["rm -rf "++?ControllerDir],5000),
    rpc:call(Node,os,cmd,["git clone "++?MbedControllerGitPath++" "++?ControllerDir],5000),
    HostEbin=filename:join(?ControllerDir,"ebin"),
    true=rpc:call(Node,code,add_patha,[HostEbin],5000),
    ok.

git_clone_host_files(Node)->
    rpc:call(Node,os,cmd,["rm -rf "++?HostFilesDir],5000),
    rpc:call(Node,os,cmd,["git clone "++?HostSpecsGitPath++" "++?HostFilesDir],5000),
    true=rpc:call(Node,code,add_patha,[?HostFilesDir],5000),
    ok.

git_clone_appl_files(Node)->
    rpc:call(Node,os,cmd,["rm -rf "++?ApplSpecsDir],5000),
    rpc:call(Node,os,cmd,["git clone "++?ApplSpecsGitPath++" "++?ApplSpecsDir],5000),
    true=rpc:call(Node,code,add_patha,[?ApplSpecsDir],5000),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
