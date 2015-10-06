library idb_shim.idb_test_common;

import 'package:logging/logging.dart';
//import 'package:unittest/unittest.dart';
import 'package:idb_shim/idb_client.dart';
import 'package:idb_shim/src/common/common_meta.dart';
import 'package:idb_shim/idb_client_sembast.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:sembast/sembast.dart' as sdb;
export 'package:idb_shim/idb_client_memory.dart';
import 'dart:async';

import 'common_meta_test.dart';
//export 'common_meta_test.dart' hide main;
export 'package:idb_shim/src/common/common_meta.dart';
//export 'package:tekartik_test/test_utils.dart';
import 'package:dev_test/test.dart';
export 'package:dev_test/test.dart';
export 'dart:async';
import 'package:path/path.dart';

// only for test - INFO - basic output, FINE - show test name before/after - FINEST - samething for console test also
const Level debugLevel = Level.FINE;
const String testDbName = 'test.db';
const String testStoreName = 'test_store';
const String testStoreName2 = 'test_store_2';

const String testNameIndex = 'name_index';
const String testNameField = 'name';
const String testValueIndex = 'value_index';
const String testValueField = 'value';

const String testNameIndex2 = 'name_index_2';
const String testNameField2 = 'name_2';

class TestContext {
  IdbFactory factory;
  String get dbName => testDescriptions.join('-') + ".db";
}

class SembastTestContext extends TestContext {
  sdb.DatabaseFactory sdbFactory;
  IdbSembastFactory get factory => super.factory;
  String get dbName => join(joinAll(testDescriptions), "test.db");
}

TestContext idbMemoryContext = new SembastTestContext()
  ..factory = idbMemoryFactory;

IdbFactory idbTestMemoryFactory = idbMemoryFactory;

Future<Database> setUpSimpleStore(IdbFactory idbFactory, //
    {String dbName: testDbName,
    IdbObjectStoreMeta meta}) {
  if (meta == null) {
    meta = idbSimpleObjectStoreMeta;
  }
  return idbFactory.deleteDatabase(dbName).then((_) {
    void _initializeDatabase(VersionChangeEvent e) {
      Database db = e.database;
      ObjectStore objectStore = db.createObjectStore(meta.name,
          keyPath: meta.keyPath, autoIncrement: meta.autoIncrement);
      for (IdbIndexMeta indexMeta in meta.indecies) {
        objectStore.createIndex(indexMeta.name, indexMeta.keyPath,
            unique: indexMeta.unique, multiEntry: indexMeta.multiEntry);
      }
    }
    return idbFactory.open(dbName,
        version: 1, onUpgradeNeeded: _initializeDatabase);
  });
}

bool isDatabaseError(e) {
  return (e is DatabaseError);
}

bool isTransactionReadOnlyError(e) {
  if (e is DatabaseError) {
    String message = e.toString().toLowerCase();
    if (message.contains('readonly')) {
      return true;
    }
    if (message.contains('read_only')) {
      return true;
    }
  }
  return false;
}

bool isStoreNotFoundError(e) {
  if (e is DatabaseError) {
    String message = e.toString().toLowerCase();
    if (message.contains('notfounderror')) {
      return true;
    }
  }
  return false;
}
