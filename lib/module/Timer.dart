import 'package:flutter_metawear/code_block.dart';
import 'package:flutter_metawear/meta_wear_board.dart';

/// A task comprising of MetaWear commands programmed to run on-board at a certain times
abstract class ScheduledTask {
  /// Start task execution
  void start();

  /// Stop task execution
  void stop();

  /// Checks if this object represents an active task
  /// @return True if task is still scheduled on-board
  bool isActive();

  /// Get the numerical id of this task
  /// @return Task ID
  int id();

  /// Removes this task from the board
  void remove([bool sync]);
}

/// On-board scheduler for executing MetaWear commands in the future

abstract class Timer implements Module {
  /// Schedule a task to be indefinitely executed on-board at fixed intervals
  /// @param period    How often to execute the task, in milliseconds
  /// @param delay     True if first execution should be delayed by one {@code delay}
  /// @param mwCode    MetaWear commands composing the task
  /// @return Task holding the result of the scheduled request
  /// @see ScheduledTask
  Future<ScheduledTask> scheduleAsync(int period, bool delay, CodeBlock mwCode);

  /// Schedule a task to be executed on-board at fixed intervals for a specific number of repetitions
  /// @param period         How often to execute the task, in milliseconds
  /// @param repetitions    How many times to execute the task
  /// @param delay          True if first execution should be delayed by one {@code delay}
  /// @param mwCode         MetaWear commands composing the task
  /// @return Task holding the result of the scheduled task
  /// @see ScheduledTask
  Future<ScheduledTask> scheduleAsyncRepeated(
      int period, int repetitions, bool delay, CodeBlock mwCode);

  /// Find the {@link ScheduledTask} object corresponding to the given id
  /// @param id    Task id to lookup
  /// @return Schedule task matching the id, null if no matches
  ScheduledTask? lookupScheduledTask(int id);
}
