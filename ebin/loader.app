%% This is the application resource file (.app file) for the 'base'
%% application.
{application, loader,
[{description, "Loader application and cluster" },
{vsn, "0.0.1" },
{modules, 
	  [loader,loader_sup,loader_app,loader_server,
	   appl_mgr,lib_appl_mgr,appl_mgr_server,
	   sd,lib_sd,sd_sup,sd_app,sd_server]},
{registered,[loader]},
{applications, [kernel,stdlib]},
{mod, {loader_app,[]}},
{start_phases, []},
{git_path,"https://github.com/joq62/loader.git"},
{constraints,[]}
]}.
