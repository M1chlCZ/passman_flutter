class BlocWrapper<T> {
  Status status;
  T? data;
  String? message;

  BlocWrapper.loading(this.message) : status = Status.loading;
  BlocWrapper.completed(this.data) : status = Status.completed;
  BlocWrapper.error(this.message) : status = Status.error;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { loading, completed, error}