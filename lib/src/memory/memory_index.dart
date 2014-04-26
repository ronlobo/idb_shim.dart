part of idb_memory;

class _MemoryIndex extends Index {
  _MemoryObjectStoreData data;
  MemoryObjectStore get store => data.store;
  String name;
  String keyPath;
  bool unique;
  bool multiEntry;

  _MemoryTransaction get transaction => store.transaction;

  // Ordered keys
  List keys = new List();

  Map<dynamic, _MemoryItem> itemsByKey = new Map();
  _MemoryIndex(this.data, this.name, this.keyPath, this.unique, this.multiEntry) {
    // Build the index based on the existing
    // TODO
  }

  List filterKeysByRange(CommonKeyRange range) {
    if (range == null) {
      return keys;
    } else {
      // Apply range
      List keys = new List();
      this.keys.forEach((key) {
        if (range.contains(key)) {
          //print('$key ok');
          keys.add(key);
        }
      });
      return keys;
    }
  }

  List filterKeysByKey(key) {

    // Apply range
    List keys = [key];
    return keys;
  }

  _MemoryItem getSync(key) {
    var item = itemsByKey[key];
    return item;
  }

  void setSync(key, _MemoryItem item) {
    itemsByKey[key] = item;
  }

  Future inTransaction(computation()) {
    return store.inTransaction(computation);
  }

  Future get(key) {
    return inTransaction(() {
      return _MemoryItem.safeValue(getSync(key));
    });
  }

  dynamic getItemKey(_MemoryItem item) {
    if (keyPath == null) {
      return item.key;
    }
    return item[keyPath];
  }

  Future<int> count([key_OR_range]) {
    if (key_OR_range is CommonKeyRange) {
      return new Future.value(filterKeysByRange(key_OR_range).length);
    } else if (key_OR_range == null) {
      return new Future.value(keys.length);
    }
    throw new ArgumentError("not supported");
  }

  void updateIndex(_MemoryItem item, [_MemoryItem oldItem]) {

    var key = getItemKey(item);
    var oldKey;

    if (oldItem != null) {
      oldKey = getItemKey(oldItem);
    }

    if (oldKey != null) {
      if (oldKey != key) {
        removeIndex(oldItem);
      } else {
        itemsByKey[key] = item;
        return;
      }
    } else {
      // Add and sort
      keys.add(key);
      keys.sort();

      itemsByKey[key] = item;
    }
  }

  void removeIndex(_MemoryItem item) {
    var key = getItemKey(item);

    keys.remove(key);
    itemsByKey.remove(key);
  }


  Stream<CursorWithValue> openCursor({key, KeyRange range, String direction, bool autoAdvance}) {
    if (direction == null) {
      direction = DIRECTION_NEXT;
    }
    if (autoAdvance == null) {
      autoAdvance = true;
    }

    _MemoryCursorWithValueController ctlr = new _MemoryCursorWithValueController(this, key, range as CommonKeyRange, direction, autoAdvance);

    // future
    inTransaction(() {
      // must check for begin
      return ctlr.execute();
    });

    return ctlr.stream;
  }

  Stream<Cursor> openKeyCursor({key, KeyRange range, String direction, bool autoAdvance}) {
    if (direction == null) {
      direction = DIRECTION_NEXT;
    }
    if (autoAdvance == null) {
      autoAdvance = true;
    }
    MemoryCursorController ctlr = new MemoryCursorController(this, //
    key, range as CommonKeyRange, direction, autoAdvance);

    // future
    inTransaction(() {
      return transaction._enqueueFuture(ctlr.execute());
    });

    return ctlr.stream;
  }

  // Checking the index means loading from
  Future _checkIndex() {
    return store._checkStoreOld();
  }
}

class MemoryPrimaryIndex extends _MemoryIndex {
  dynamic getKey(key) {
    return key;
  }
  MemoryPrimaryIndex(_MemoryObjectStoreData data, String keyPath): super(data, null, keyPath, true, false) {

  }
}

class AutoIncrementMemoryPrimaryIndex extends MemoryPrimaryIndex {
  int autoIncrementIndex = 0;
  AutoIncrementMemoryPrimaryIndex(_MemoryObjectStoreData data, String keyPath): super(data, keyPath) {
  }

  @override
  dynamic getKey(key) {
    if (key != null) {
      if (key > autoIncrementIndex) {
        autoIncrementIndex = key;
      }
      return key;
    }
    return ++autoIncrementIndex;

  }


}
