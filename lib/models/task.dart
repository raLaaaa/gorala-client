import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task(this.id);

  final String id;

  @override
  List<Object> get props => [id];

  static const empty = Task('-');
}