import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/task_repository.dart';
import 'package:gorala/models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;
  final Map<DateTime, List<Task>> _cachedEntries = Map();

  TaskCubit(this._taskRepository) : super(TasksEmpty());

  Future<void> getAllTasksOfUser() async {
    emit(TasksLoading());
    Map<DateTime, List<Task>> tasks = await _taskRepository.fetchAllTasksOfUser();

    if (tasks == null) {
      Map<DateTime, List<Task>> tasks = Map();
      emit(TasksLoaded(_cachedEntries));
      return;
    }

    _cachedEntries.addAll(tasks);
    emit(TasksLoaded(_cachedEntries));
  }

  Future<void> getAllTasksOfUserByDate(DateTime time) async {
    emit(TasksLoading());
    Map<DateTime, List<Task>> tasks = await _taskRepository.fetchAllTasksOfUserByDate(time);

    if (tasks == null) {
      Map<DateTime, List<Task>> tasks = Map();
      emit(TasksLoaded(_cachedEntries));
      return;
    }

    _cachedEntries.addAll(tasks);
    emit(TasksLoaded(_cachedEntries));
  }

  Future<void> getAllTasksOfUserByDateWithRange(DateTime time) async {
    emit(TasksLoading());
    Map<DateTime, List<Task>> tasks = await _taskRepository.fetchAllTasksOfUserByDateWithRange(time);

    if (tasks == null) {
      Map<DateTime, List<Task>> tasks = Map();
      emit(TasksLoaded(_cachedEntries));
      return;
    }

    _cachedEntries.addAll(tasks);
    emit(TasksLoaded(_cachedEntries));
  }
}
