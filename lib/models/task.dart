import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Task extends Equatable {
  const Task(this.id, this.description, this.isFinished, this.isCarryOnTask, this.executionDate, this.createdAt);

  final String id;
  final String description;
  final bool isFinished;
  final bool isCarryOnTask;
  final DateTime executionDate;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, description, isFinished, isCarryOnTask, executionDate, createdAt];

  String getExecutionDateFormatted() {
    DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
    return _dateFormat.format(executionDate);
  }
}
