import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task(this.id, this.description, this.executionDate);

  final String id;
  final String description;
  final DateTime executionDate;

  @override
  List<Object> get props => [id, description, executionDate];

}