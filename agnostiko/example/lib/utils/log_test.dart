class LogTest {
  String title;
  Future<LogTestResult> Function() function;

  LogTest(this.title, this.function);
}

class LogTestResult {
  bool success;
  String? infoMsg;

  LogTestResult(this.success, {this.infoMsg});
}
