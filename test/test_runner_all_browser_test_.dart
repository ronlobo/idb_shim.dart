@TestOn("browser")
library idb_shim.test_runner_all_browser_test;

import 'test_runner_client_native_test.dart' as native;
import 'test_runner_client_websql_test.dart' as websql;
import 'test_runner_client_sembast_memory_test.dart' as sembast_memory;
import 'idb_browser_test.dart' as browser;
import 'common_value_test.dart' as common_value_test;
import 'idb_test_common_test.dart' as idb_test_common_test;
import 'test_runner.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:test/test.dart';

main() {
  native.main();
  websql.main();
  sembast_memory.main();

  browser.main();
  common_value_test.main();
  idb_test_common_test.main();
  defineTests(idbSembastMemoryFactory);
}