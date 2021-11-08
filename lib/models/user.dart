import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id, this.email, this.authToken);

  final String id;
  final String email;
  final String authToken;

  @override
  List<Object> get props => [id, email, authToken];

}