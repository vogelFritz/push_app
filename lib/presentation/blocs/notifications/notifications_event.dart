part of 'notifications_bloc.dart';

class NotificationsEvent {}

class NotificationsStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  NotificationsStatusChanged(this.status);
}
