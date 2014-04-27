part of idb_native;

class _NativeTransaction extends Transaction {
  idb.Transaction idbTransaction;



  _NativeTransaction(Database database, this.idbTransaction) : super(database);
  
  @override
  ObjectStore objectStore(String name) {
    idb.ObjectStore idbObjectStore = idbTransaction.objectStore(name);
    return new _NativeObjectStore(idbObjectStore);
  }
  
  @override
  Future<Database> get completed {
    return idbTransaction.completed.then((_) {
      return database;
    });
  }
  
}