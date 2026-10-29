import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin notifikasi & timezone
  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // Method yang dipanggil oleh BookingProvider
  Future<void> scheduleBookingReminder({
    required int id,
    required String serviceName,
    required DateTime bookingTime,
  }) async {
    try {
      // Set pengingat (misal 1 jam sebelum jadwal booking)
      final reminderTime = bookingTime.subtract(const Duration(hours: 1));

      // Jika waktu pengingat sudah lewat dari waktu sekarang, jangan jadwalkan
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint("Waktu pengingat sudah terlewat, notifikasi tidak dijadwalkan.");
        return;
      }

      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'booking_reminder_channel',
        'Pengingat Booking Salon',
        channelDescription: 'Notifikasi pengingat sebelum jadwal booking salon dimulai',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        'Pengingat Jadwal Salon!',
        'Jadwal perawatan $serviceName kamu tinggal 1 jam lagi.',
        tz.TZDateTime.from(reminderTime, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("Notifikasi pengingat berhasil dijadwalkan untuk ID: $id");
    } catch (e) {
      debugPrint("Error saat menjadwalkan notifikasi: $e");
    }
  }

  // Method untuk membatalkan notifikasi saat booking dihapus/dibatalkan
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint("Notifikasi dengan ID $id berhasil dibatalkan.");
    } catch (e) {
      debugPrint("Error saat membatalkan notifikasi: $e");
    }
  }
}