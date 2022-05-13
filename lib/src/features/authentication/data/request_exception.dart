class BackendRequestException extends Error {
  BackendRequestException(this.error);
  final String error;
}
