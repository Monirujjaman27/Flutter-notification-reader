import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:sync_message/src/sms/sms_controller.dart';

import '../settings/settings_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    SMSController msgController = Get.put(SMSController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time check Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
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
                        onTap: () async {
                          try {
                            await event.sendReply("This is an auto response");
                          } catch (e) {
                            log(e.toString());
                          }
                        },
                        trailing: event.hasRemoved!
                            ? const Text(
                                "Removed",
                                style: TextStyle(color: Colors.red),
                              )
                            : const SizedBox.shrink(),
                        leading: event.appIcon == null
                            ? const SizedBox.shrink()
                            : Image.memory(
                                event.appIcon!,
                                width: 35.0,
                                height: 35.0,
                              ),
                        title: Text(
                          event.title ?? "No title",
                          style: TextStyle(
                            fontWeight: event.hasRemoved!
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.content ?? "no content",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            event.canReply!
                                ? const Text(
                                    "Replied with: This is an auto reply",
                                    style: TextStyle(color: Colors.purple),
                                  )
                                : const SizedBox.shrink(),
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
          ],
        ),
      ),
    );
  }
}
