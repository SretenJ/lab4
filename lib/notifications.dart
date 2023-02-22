import 'package:awesome_notifications/awesome_notifications.dart';

import 'models/ispit.dart';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

Future<void> createExamDayBeforeNotification(Ispit examToNotify) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'scheduler_channel',
      title: '${examToNotify.ime} Exam tomorrow',
      body:
          'You have an exam tomorrow at ${examToNotify.vreme.hour} : ${examToNotify.vreme.minute} ${Emojis.paper_open_book}',
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'CONFIRM',
        label: 'Confirm',
      )
    ],
  );
  //schedule: NotificationCalendar.fromDate(date: examToNotify.datum));
  //schedule: NotificationCalendar.fromDate(date: DateTime.now()));
}
