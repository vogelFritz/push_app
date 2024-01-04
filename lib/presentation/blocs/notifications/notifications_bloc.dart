import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_state.dart';
part 'notifications_event.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  final Future<void> Function()? requestLocalNotificationPermissions;
  final void Function(
      {required int id,
      String? title,
      String? body,
      String? data})? showLocalNotification;

  NotificationsBloc(
      {this.requestLocalNotificationPermissions, this.showLocalNotification})
      : super(const NotificationsState()) {
    on<NotificationsStatusChanged>(_notificationsStatusChanged);
    on<NotificationReceived>(_onPushMessage);
    _initialStatusCheck();
    _onForegroundMessage();
  }

  void _onPushMessage(event, emit) {
    emit(state
        .copyWith(notifications: [event.pushMessage, ...state.notifications]));
  }

  static Future<void> initializeFirebaseNotifications() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  void _notificationsStatusChanged(event, emit) {
    emit(state.copyWith(status: event.status));
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationsStatusChanged(settings.authorizationStatus));
    _getFCMToken();
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print('$token');
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;
    final notification = PushMessage(
        messageId:
            message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: Platform.isAndroid
            ? message.notification!.android?.imageUrl
            : message.notification!.apple?.imageUrl);

    if (showLocalNotification != null) {
      showLocalNotification!(
          id: ++pushNumberId,
          title: notification.title,
          body: notification.body,
          data: notification.messageId);
    }
    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
    }
    add(NotificationsStatusChanged(settings.authorizationStatus));
    _getFCMToken();
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exists = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exists) return null;
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}
