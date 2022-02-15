all:
#	service
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf leader myadd mydivi sd service;
	rm -rf appl_specs host_specs;
	rm -rf  *~ */*~  erl_cra*;
#	common
	cp ../common/src/*.app ebin;
	erlc -I ../infra/log_server/include -o ebin ../common/src/*.erl;
#	flatlog
#	cp flatlog/_build/default/lib/flatlog/ebin/* ebin;
#	sd
	cp ../sd/src/*.app ebin;
	erlc -I ../infra/log_server/include -o ebin ../sd/src/*.erl;
#	boot_loader
#	cp boot_loader/src/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin boot_loader/*.erl;
#	leader
	cp ../leader/src/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin ../leader/src/*.erl;
#	loader
	cp loader/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin loader/*.erl;
#	appl_mgr
	cp appl_mgr/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin appl_mgr/*.erl;
#	host
	cp host/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin host/*.erl;
#	controller
	cp controller/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin controller/*.erl;
	echo Done
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf leader myadd mydivi sd service;
	rm -rf appl_specs host_specs;
	mkdir test_ebin;
#	common
	cp ../common/src/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -o test_ebin ../common/src/*.erl;
#	sd
	cp ../sd/src/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -o ebin ../sd/src/*.erl;
#	flatlog
#	cp flatlog/_build/default/lib/flatlog/ebin/* ebin;
#	boot_loader
#	cp boot_loader/src/*.app ebin;2
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin boot_loader/*.erl;
#	loader
	cp loader/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin loader/*.erl;
#	appl_mgr
	cp appl_mgr/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin appl_mgr/*.erl;
#	leader
	cp ../leader/src/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin ../leader/src/*.erl;
#	host
	cp host/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin host/*.erl;
#	controller
	cp controller/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o ebin controller/*.erl;
#	test application
	cp test_src/*.app test_ebin;
	erlc -D unit_test -I ../infra/log_server/include -I include -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie cookie_test\
	    -sname test\
	    -unit_test monitor_node test\
	    -unit_test cluster_id test\
	    -unit_test cookie cookie_test\
	    -run unit_test start_test test_src/test.config
host_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf leader myadd mydivi sd service;
	rm -rf appl_specs host_specs;
	mkdir test_ebin;
#	common
	cp ../common/src/*.app ebin;
	erlc -I ../infra/log_server/include -o test_ebin ../common/src/*.erl;
#	sd
	cp ../sd/src/*.app ebin;
	erlc -I ../infra/log_server/include -o ebin ../sd/src/*.erl;
#	boot_loader
#	cp boot_loader/src/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin boot_loader/*.erl;
#	host
	cp host/*.app ebin;
	erlc -I ../infra/log_server/include -I include -o ebin host/*.erl;
#	test application
	cp test_src/*.app test_ebin;
	erlc -I ../infra/log_server/include -I include -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie cookie_test\
	    -sname test\
	    -unit_test monitor_node test\
	    -unit_test cluster_id test\
	    -unit_test cookie cookie_test\
	    -run unit_test start_test test_src/test.config
fun_test:
	erl -sname a -setcookie cookie_test
