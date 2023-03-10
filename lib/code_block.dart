/// Interface for saving MetaBase commands to the board
abstract class CodeBlock {
  /// Saves the MetaWear commands used in implementations of this function to the board.  The commands
  /// are only executed when triggered by an internal event
  void program();
}
