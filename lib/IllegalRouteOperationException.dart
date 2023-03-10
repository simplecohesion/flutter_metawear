/// Exception indicating that an illegal route operation was attempted.

class IllegalRouteOperationException extends Error {
//    private static final long serialVersionUID = -418823318014857905L;

  Error? cause;
  final String message;

  IllegalRouteOperationException(this.message, {this.cause});

  @override
  String toString() {
    return "IllegalRouteOperationException:$cause";
  }

//    public IllegalRouteOperationException(String message, Exception cause) {
//        super(message, cause);
//    }
}
