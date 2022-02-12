% host
-define(ControllerDir,"mbed_controller").
-define(HostNodesFile,"host_specs/host.nodes").
-define(MbedControllerGitPath,"https://github.com/joq62/mbed_controller.git").
-define(HostFilesDir,"host_specs").
% appl_mgr
-define(ApplSpecsDir,"appl_specs").
-ifdef(unit_test).
-define(HostSpecsGitPath,"https://github.com/joq62/test_host_specs.git").
-define(ApplSpecsGitPath,"https://github.com/joq62/test_appl_specs.git").
-else.
-define(HostSpecsGitPath,"https://github.com/joq62/host_specs.git").
-define(ApplSpecsGitPath,"https://github.com/joq62/appl_specs.git").
-endif.
%----------------------------------------------------------------
-define(RootDir,".").

%----------------------------------------------------------------




