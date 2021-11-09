import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/task_repository.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;

  TaskCubit(this._taskRepository) : super(TasksEmpty());

  Future<void> getTasksOfUser() async {
      emit(TasksLoading());
      List<Task> tasks = await _taskRepository.fetchTasksOfUser();

      if(tasks == null){
        emit(TasksEmpty());
        return;
      }

      emit(TasksLoaded(tasks));
  }
}