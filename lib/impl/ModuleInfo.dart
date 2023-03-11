import 'dart:typed_data';

import 'package:flutter_metawear/impl/util.dart';

/// Created by etsai on 8/31/16.
class ModuleInfo {
//    private static final long serialVersionUID = -8120230312302254264L;

  final int id, implementation, revision;
  final Uint8List extra;

  ModuleInfo._(this.id, this.implementation, this.revision, this.extra);

  factory ModuleInfo(Uint8List response) {
    int id = response[0];
    int implementation;
    int revision;
    Uint8List extra;

    if (response.length > 2) {
      implementation = response[2];
      revision = response[3];
    } else {
      implementation = 0xff;
      revision = 0xff;
    }
    if (response.length > 4) {
      extra = Uint8List(response.length - 4);
      extra.setAll(0, response.skip(4));
    } else {
      extra = Uint8List(0);
    }

    return ModuleInfo._(id, implementation, revision, extra);
  }

  bool present() {
    return implementation != 0xff && revision != 0xff;
  }

  Map<String, dynamic> toJSON() {
    if (!present()) {
      return Map();
    }

    Map<String, dynamic> attributes = Map();
    attributes["implementation"] = implementation;
    attributes["revision"] = revision;

    if (extra.length > 0) {
      attributes["extra"] = Util.arrayToHexString(extra);
    }

    return attributes;
  }
}
