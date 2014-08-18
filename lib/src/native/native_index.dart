part of idb_native;

class _NativeIndex extends Index {
  idb.Index idbIndex;
  _NativeIndex(this.idbIndex);

  @override
  Future get(dynamic key) {
    return idbIndex.get(key);
  }

  @override
  Future getKey(dynamic key) {
    return idbIndex.getKey(key);
  }

  @override
  Future<int> count([key_OR_range]) {
    Future<int> countFuture;
    if (key_OR_range == null) {
      countFuture = idbIndex.count();
    } else if (key_OR_range is KeyRange) {
      idb.KeyRange idbKeyRange = _nativeKeyRange(key_OR_range);
      countFuture = idbIndex.count(idbKeyRange);
    } else {
      countFuture = idbIndex.count(key_OR_range);
    }
    return countFuture;
  }

  @override
  Stream<Cursor> openKeyCursor({key, KeyRange range, String direction, bool autoAdvance}) {
    _NativeCursorController ctlr = new _NativeCursorController(idbIndex.openKeyCursor(key: key, range: range == null ? null : _nativeKeyRange(range), direction: direction, autoAdvance: autoAdvance));
    return ctlr.stream;
  }

  /**
   * Same implementation than for the Store
   */
  @override
  Stream<CursorWithValue> openCursor({key, KeyRange range, String direction, bool autoAdvance}) {
    _NativeCursorWithValueController ctlr = new _NativeCursorWithValueController(idbIndex.openCursor(key: key, range: range == null ? null : _nativeKeyRange(range), direction: direction, autoAdvance: autoAdvance));

    return ctlr.stream;
  }
}
