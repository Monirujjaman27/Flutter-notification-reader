import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:sync_message/src/sms/sms_controller.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  static const routeName = '/';
  Text _titleController(dynamic event) {
    // Ensure event.title is not null and has a value
    if (event.title == null || event.title.isEmpty) {
      return Text('');
    }

    // Split the string by ": "
    List<String> exTtl = event.title.split(": ");
    String pkg = '';

    // Ensure event.packageName is not null and contains the substring
    if (event.packageName != null) {
      if (event.packageName.contains('whatsapp')) {
        pkg = "(Whatsapp)";
      } else if (event.packageName.contains('facebook')) {
        pkg = "(Facebook)";
      } else if (event.packageName.contains('google')) {
        pkg = "(Message)";
      }
    }

    // Check if the split resulted in more than one part
    String ttl = '';
    if (exTtl.length > 1) {
      ttl = exTtl[1]; // Return the second part
    } else {
      ttl = event.title; // Return the original title if no split was found
    }

    // Return a Text widget with dynamic styling
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: ttl,
            style: TextStyle(
              fontWeight:
                  event.hasRemoved! ? FontWeight.normal : FontWeight.bold,
              fontSize: 16, // Adjust the size for ttl as needed
            ),
          ),
          TextSpan(
            text: ' $pkg',
            style: TextStyle(
              fontWeight:
                  event.hasRemoved! ? FontWeight.normal : FontWeight.bold,
              fontSize: 12, // Smaller size for pkg
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SMSController msgController = Get.put(SMSController());
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Notification Checker'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () async {
              final res = await NotificationListenerService.requestPermission();
              print("Is enabled: $res");
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          final events = msgController.notificationList;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (_, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: event.appIcon == null
                      ? const SizedBox.shrink()
                      : Image.memory(
                          event.appIcon!,
                          width: 35.0,
                          height: 35.0,
                        ),
                  title: _titleController(event),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.content ?? "no content",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      if (event.hasRemoved!)
                        const Text(
                          "Seen",
                          style: TextStyle(color: Colors.grey),
                        ),
                      event.largeIcon != null
                          ? Image.memory(
                              event.largeIcon!,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
