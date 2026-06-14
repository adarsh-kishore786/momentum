class MomentumDBException implements Exception {
  final String message;
  final Object? cause;

  const MomentumDBException(this.message, {this.cause});
  
  @override
  String toString() => 
    'MomentumDBException: $message${cause != null ? " (caused by: $cause)" : ""}';
}
