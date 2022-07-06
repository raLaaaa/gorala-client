class TimeUtil {
  static DateTime convertToLocalWithoutTime(DateTime timeFromServer) {
    return DateTime(timeFromServer.year, timeFromServer.month, timeFromServer.day, 0, 0, 0, 0).toLocal();
  }
}
