import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Task extends Equatable {
  const Task(this.id, this.description, this.isFinished, this.executionDate);

  final String id;
  final String description;
  final bool isFinished;
  final DateTime executionDate;

  @override
  List<Object> get props => [id, description, isFinished, executionDate];

  String getDateFormatted() {
    DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
    return _dateFormat.format(executionDate);
  }
}
