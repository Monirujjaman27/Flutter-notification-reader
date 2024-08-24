import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class SMSController extends GetxController {
  RxList notificationList = RxList<ServiceNotificationEvent>();
  Set<String> seenNotificationContents = {};

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    listen_notification();
  }

  void reqForNotification() async {
    print('calling checked..');

    /// check if notification permession is enebaled
    final bool status = await NotificationListenerService.isPermissionGranted();
    print(status);
    if (status != true) {
      print('no permission');
      final bool status = await NotificationListenerService.requestPermission();
      return;
    }
    listen_notification();
  }

  void listen_notification() async {
    print('check notification');
    NotificationListenerService.notificationsStream.listen((event) {
      seenNotificationContents
          .add(event.content!); // Add the content to the set to track it
      print(event);
      if (event.title != 'Messaging is running' ||
          event.content != 'Checking for new messages') {
        print(seenNotificationContents);

        if (event.content?.contains("new messages") == false) {
          // if (!seenNotificationContents.contains(event.content)) {
            notificationList.add(event);
          // }
        }
      }
    });
  }
}
