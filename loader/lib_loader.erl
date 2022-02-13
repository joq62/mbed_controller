%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_loader).   
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
-include("configs.hrl").
-include_lib("kernel/include/logger.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%
%-define(ScheduleInterval,20*1000).
%-define(ConfigsGitPath,"https://github.com/joq62/configs.git").
%-define(ConfigsDir,filename:join(?ApplMgrConfigDir,"configs")).
%-define(ApplicationsDir,filename:join(?ConfigsDir,"applications")).
%-define(ApplMgrConfigDir,"appl_mgr.dir").

%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 git_load_host_files/0,
	 git_update_host_files/0,

	 load_appl/2,
	 load_appl/3,
	 unload_appl/2,
	 start_appl/2,
	 stop_appl/2
	
	]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
git_load_host_files()->
    os:cmd("rm -rf "++?HostFilesDir),
    os:cmd("git clone "++?HostSpecsGitPath),
    ok.

    
git_update_host_files()->
    {error,[not_implmented]}.
		   
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
load_appl(Appl,Vm)->
    Result=case appl_mgr:get_appl_dir(Appl) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,ApplDirPath}->
		   do_load(Appl,ApplDirPath,Vm)
	   end,
    Result.

load_appl(Appl,Vsn,Vm)->
    Result=case appl_mgr:get_appl_dir(Appl,Vsn) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,ApplDirPath}->
		   do_load(Appl,ApplDirPath,Vm)
	   end,
    Result.    





do_load(Appl,ApplDirPath,Vm)->
    io:format("Appl,ApplDirPath,Vm ~p~n",[{Appl,ApplDirPath,Vm,?MODULE,?FUNCTION_NAME,?LINE}]),
    EbinPath=filename:join(ApplDirPath,"ebin"),
    Result=case rpc:call(Vm,code,add_patha,[EbinPath],30*1000) of
	       {Error,Reason}->
		   {Error,Reason};
	       true->
		   case rpc:call(Vm,application,load,[Appl],30*1000) of
		       {Error,Reason}->
			   {Error,Reason};
		       ok->
			   ok
		   end
	   end,
    Result.
    
    %% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
unload_appl(Appl,Vm)->
    rpc:call(Vm,application,unload,[Appl],30*1000).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_appl(Appl,Vm)->
    rpc:call(Vm,application,start,[Appl],30*1000).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
stop_appl(Appl,Vm)->
    rpc:call(Vm,application,stop,[Appl],30*1000).

