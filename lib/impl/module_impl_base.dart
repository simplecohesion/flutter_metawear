import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';

abstract class ModuleImplBase {
  static final int serialVersionUID = -8904360854647238719;
  MetaWearBoardPrivate mwPrivate;

  ModuleImplBase(this.mwPrivate) {
    init();
  }

  void restoreTransientVars(MetaWearBoardPrivate mwPrivate) {
    this.mwPrivate = mwPrivate;
    init();
  }

  void init() {}
  void tearDown() {}
  void disconnected() {}
}
