part of 'task_cubit.dart';

abstract class TaskState {
  const TaskState();
}

class TasksEmpty extends TaskState {
  const TasksEmpty();
}

class TasksLoading extends TaskState {
  const TasksLoading();
}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  const TasksLoaded(this.tasks);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TasksLoaded && o.tasks == tasks;
  }

  @override
  int get hashCode => tasks.hashCode;
}

class TasksError extends TaskState {
  final String message;
  const TasksError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TasksError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}