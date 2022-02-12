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
-include("configs.hrl").
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

%    io:format("~p~n",[{"Start boot()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok= boot(),
%    io:format("~p~n",[{"Stop  boot()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=start_script(),
%    io:format("~p~n",[{"Stop  start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start loader_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= loader_vm(),
    io:format("~p~n",[{"Stop  loader_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= appl_mgr(),
    io:format("~p~n",[{"Stop  appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start loader_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= loader_appl(),
    io:format("~p~n",[{"Stop  loader_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),


    io:format("~p~n",[{"Start service()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=service(),
    io:format("~p~n",[{"Stop  service()",?MODULE,?FUNCTION_NAME,?LINE}]),

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
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

loader_vm()->
  % Test loader initiated in loader_init
    [H1|_]=test_nodes:get_nodes(),
  %  ok=application:start(loader),
    [LoaderVm]=rpc:call(H1,sd,get,[loader],5000),
    {ok,N1}=rpc:call(LoaderVm,loader,create,[],5000),
    pong=net_adm:ping(N1),
    Test1=test_1@c100,
    {ok,Test1}=rpc:call(LoaderVm,loader,create,["test_1"],5000),
    pong=net_adm:ping(Test1),
    
    ok=rpc:call(LoaderVm,loader,delete,[N1],5000),
    pang=net_adm:ping(N1),

    ok=rpc:call(LoaderVm,loader,delete,[Test1]),
    pang=net_adm:ping(Test1),

    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
appl_mgr()->
    % Test loader initiated in loader_init
    [H1|_]=test_nodes:get_nodes(),
    [LoaderVm]=rpc:call(H1,sd,get,[loader],5000),
   
%    ok=rpc:call(H1,appl_mgr,load_specs,[],5000),
%    io:format(" ~p~n",[{rpc:call(LoaderVm,appl_mgr,get_all_appl_info,[],5000),?FUNCTION_NAME,?MODULE,?LINE}]),
    {ok,AllInfo}=rpc:call(LoaderVm,appl_mgr,get_all_appl_info,[],5000),
    [{{myadd,"1.0.0"},"myadd/1.0.0"},
     {{mydivi,"1.0.0"},"mydivi/1.0.0"}]=lists:sort(AllInfo),

    {ok,"myadd/1.0.0"}=rpc:call(LoaderVm,appl_mgr,get_appl_dir,[myadd,"1.0.0"],5000),
    {ok,"myadd/1.0.0"}=rpc:call(LoaderVm,appl_mgr,get_appl_dir,[myadd,latest],5000),
   

   %get types info per ap constraints
    {ok,"https://github.com/joq62/myadd.git"}=rpc:call(LoaderVm,appl_mgr,get_info,[myadd,"1.0.0",git_path],5000),
    {ok,[]}=rpc:call(LoaderVm,appl_mgr,get_info,[myadd,"1.0.0",constraints],5000),
    
    {ok,"https://github.com/joq62/mydivi.git"}=rpc:call(LoaderVm,appl_mgr,get_info,[mydivi,"1.0.0",git_path],5000),
    {ok,[{host,h202@c100}]}=rpc:call(LoaderVm,appl_mgr,get_info,[mydivi,"1.0.0",constraints],5000),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
loader_appl()->
   
    % Test loader initiated in loader_init
    [H1|_]=test_nodes:get_nodes(),
    % Start a Vm  

    [H1|_]=test_nodes:get_nodes(),
    [LoaderVm]=rpc:call(H1,sd,get,[loader],5000),

    {ok,N1}=rpc:call(LoaderVm,loader,create,[],5000),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)), 
    % Load an application  
    ok=rpc:call(LoaderVm,loader,load_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Start an application   
    ok=rpc:call(LoaderVm,loader,start_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    true=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Test the application
    42=rpc:call(N1,myadd,add,[20,22],1000),
    {error,{already_started,myadd}}=rpc:call(LoaderVm,loader,start_appl,[myadd,N1],5000),    
    
   % [H1]=rpc:call(H1,sd,get,[loader],5000),

    % stop an application 
    ok=rpc:call(LoaderVm,loader,stop_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),
    % Unload an application
    ok=rpc:call(LoaderVm,loader,unload_appl,[myadd,N1],5000),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),
    
  
    ok.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
service()->
    [H1,H2,H3]=test_nodes:get_nodes(),
    io:format("sd:all ~p~n",[{rpc:call(H1,sd,all,[],2000),?FUNCTION_NAME,?MODULE,?LINE}]),

    [LoaderVm]=sd:get(loader),
    ok=rpc:call(LoaderVm,loader,load_appl,[myadd,LoaderVm],5000),
    ok=rpc:call(LoaderVm,loader,start_appl,[myadd,LoaderVm],5000),
 
    42=rpc:call(LoaderVm,myadd,add,[20,22],1000),

 
  %  [H1,H2,H3]=lists:sort(rpc:call(H1,sd,get,[loader],2000)),
  %  [H1,H2,H3]=lists:sort(rpc:call(H2,sd,get,[loader],2000)),
  %  [H1,H2,H3]=lists:sort(rpc:call(H3,sd,get,[loader],2000)),

  %  {state,worker}=rpc:call(H1,loader,read_state,[],2000),
  %  {state,worker}=rpc:call(H2,loader,read_state,[],2000),
  %  {state,controller}=rpc:call(H3,loader,read_state,[],2000),
    
    io:format("sd:get(loader) ~p~n",[{rpc:call(H1,sd,get,[loader],2000),?FUNCTION_NAME,?MODULE,?LINE}]),
    
    

    ok.
    


    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------



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
  
    ok=rpc:call(Vm1,boot_loader,do_clone_specs,[Vm1],5000),  
    true=rpc:call(Vm1,code,add_path,[Ebin],5000),
  
    ok=rpc:call(Vm1,application,start,[controller],15000),
    pong=rpc:call(Vm1,controller,ping,[],2000),
  
          
   
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
