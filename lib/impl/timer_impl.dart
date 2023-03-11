import 'dart:async';

import 'package:flutter_metawear/code_block.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/module_impl_base.dart';
import 'package:flutter_metawear/module/timer.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'dart:typed_data';
import 'EventImpl.dart';
import 'package:tuple/tuple.dart';
import 'u_int_data.dart';

class ScheduledTaskInner implements ScheduledTask {
  final int taskId;
  bool active;
  final List<int> eventCmdIds;

  MetaWearBoardPrivate mwPrivate;

  ScheduledTaskInner(this.taskId, this.eventCmdIds, this.mwPrivate,
      [this.active = true]) {
    restoreTransientVars(mwPrivate);
  }

  void restoreTransientVars(MetaWearBoardPrivate mwPrivate) {
    this.mwPrivate = mwPrivate;
  }

  @override
  void start() {
    if (active) {
      mwPrivate.sendCommand(
          Uint8List.fromList([ModuleType.TIMER.id, TimerImpl.START, taskId]));
    }
  }

  @override
  void stop() {
    if (active) {
      mwPrivate.sendCommand(
          Uint8List.fromList([ModuleType.TIMER.id, TimerImpl.STOP, taskId]));
    }
  }

  @override
  void remove([bool sync = true]) {
    if (active) {
      active = false;

      if (sync) {
        mwPrivate.sendCommand(new Uint8List.fromList(
            [ModuleType.TIMER.id, TimerImpl.REMOVE, taskId]));
        (mwPrivate.getModules()[Timer] as TimerImpl).activeTasks.remove(id);

        EventImpl event = mwPrivate.getModules()[EventImpl]! as EventImpl;
        for (int it in eventCmdIds) {
          event.removeEventCommand(it);
        }
      }
    }
  }

  @override
  int id() {
    return taskId;
  }

  @override
  bool isActive() {
    return active;
  }
}

class TimerImpl extends ModuleImplBase implements Timer {
  static const int TIMER_ENTRY = 2,
      START = 3,
      STOP = 4,
      REMOVE = 5,
      NOTIFY = 6,
      NOTIFY_ENABLE = 7;

  final Map<int, ScheduledTask> activeTasks = Map();
  final StreamController<int> _streamController = StreamController<int>();

  TimerImpl(MetaWearBoardPrivate mwPrivate) : super(mwPrivate);

  @override
  void restoreTransientVars(MetaWearBoardPrivate mwPrivate) {
    super.restoreTransientVars(mwPrivate);

    for (ScheduledTask it in activeTasks.values) {
      (it as ScheduledTaskInner).restoreTransientVars(mwPrivate);
    }
  }

  @override
  void init() {
    this.mwPrivate.addResponseHandler(Tuple2(ModuleType.TIMER.id, TIMER_ENTRY),
        (Uint8List response) => _streamController.add(response[2]));
  }

  @override
  void tearDown() {
    for (ScheduledTask it in activeTasks.values) {
      (it as ScheduledTaskInner).remove(false);
    }
    activeTasks.clear();

    for (int i = 0;
        i < mwPrivate.lookupModuleInfo(ModuleType.TIMER).extra[0];
        i++) {
      mwPrivate
          .sendCommand(Uint8List.fromList([ModuleType.TIMER.id, REMOVE, i]));
    }
  }

  Future<DataTypeBase> create(Uint8List config) async {
    Stream<int> stream =
        _streamController.stream.timeout(ModuleType.RESPONSE_TIMEOUT);
    StreamIterator<int> iterator = StreamIterator(stream);

    TimeoutException exception = TimeoutException(
        "Did not received timer id", ModuleType.RESPONSE_TIMEOUT);
    mwPrivate.sendCommandForModule(ModuleType.TIMER, TIMER_ENTRY, config);
    if (await iterator.moveNext().catchError((e) => throw exception,
            test: (e) => e is TimeoutException) ==
        false) throw exception;
    int id = iterator.current;
    await iterator.cancel();

    return UintData(ModuleType.TIMER, TimerImpl.NOTIFY,
        DataAttributes(Uint8List(0), 0, 0, false),
        id: id);
  }

  @override
  Future<ScheduledTask> scheduleAsync(
      int period, bool delay, CodeBlock mwCode) {
    return scheduleAsyncRepeated(period, -1, delay, mwCode);
  }

  @override
  Future<ScheduledTask> scheduleAsyncRepeated(
      int period, int repetitions, bool delay, CodeBlock mwCode) {
    Uint8List payload = Uint8List(7);
    ByteData data = ByteData.view(payload.buffer);
    data.setInt8(0, period);
    data.setInt16(1, repetitions);
    data.setInt8(3, delay ? 0 : 1);
    return mwPrivate.queueTaskManager(mwCode, payload);
  }

  @override
  ScheduledTask? lookupScheduledTask(int id) {
    return activeTasks[id];
  }

  ScheduledTask createTimedEventManager(int id, List<int> eventCmdIds) {
    ScheduledTaskInner newTask =
        new ScheduledTaskInner(id, eventCmdIds, mwPrivate);
    activeTasks[id] = newTask;
    return newTask;
  }
}
