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
      emit(TasksLoaded(_cachedEntries));
      return;
    }

    _cachedEntries.addAll(tasks);

    emit(TasksLoaded(_cachedEntries));
  }

  Future<void> createTask(Task task) async {
    emit(TasksLoading());
    Task createdTask = await _taskRepository.createTask(task);

    if (createdTask != null) {
      if (_cachedEntries[createdTask.executionDate] == null) {
        _cachedEntries[createdTask.executionDate] = [];
      }
      _cachedEntries[createdTask.executionDate].add(createdTask);
    } else {
      emit(TasksError('Something broke'));
      return;
    }

    emit(TasksLoaded(_cachedEntries));
  }

  Future<void> editTask(Task task) async {
    emit(TasksLoading());
    Task editedTask = await _taskRepository.editTask(task);

    if (editedTask != null) {
      _cachedEntries.forEach((key, value) {
        value.removeWhere((element) => element.id == editedTask.id);
      });

      _cachedEntries[editedTask.executionDate].add(editedTask);
    } else {
      emit(TasksError('Something broke'));
      return;
    }

    emit(TasksLoaded(_cachedEntries));
  }

  Future<void> deleteTask(Task task) async {
    emit(TasksLoading());
    bool success = await _taskRepository.deleteTask(task);

    if (success) {
      _cachedEntries.forEach((key, value) {
        value.removeWhere((element) => element.id == task.id);
      });
    } else {
      emit(TasksError('Something broke'));
      return;
    }

    emit(TasksLoaded(_cachedEntries));
  }

  void clearCachedTasks() async {
    _cachedEntries.clear();
    emit(TasksEmpty());
  }
}
