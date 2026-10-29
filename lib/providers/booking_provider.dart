import 'package:flutter/material.dart';
import 'package:booking_salon/models/booking_model.dart';
import 'package:booking_salon/services/google_calendar_service.dart';
import 'package:booking_salon/services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final List<BookingModel> _bookings = [];
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  final NotificationService _notificationService = NotificationService();

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  Future<bool> createBooking({
    required String serviceName,
    required String stylistName,
    required DateTime date,
    required String timeSlot,
    required int durationMinutes,
    required double price,
    required bool syncToCalendar,
  }) async {
    try {
      final timeParts = timeSlot.split(':');
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final bookingIdNum = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String? eventId;

      if (syncToCalendar) {
        eventId = await _calendarService.addBookingEvent(
          serviceTitle: serviceName,
          stylistName: stylistName,
          startDateTime: scheduledDateTime,
          durationMinutes: durationMinutes,
        );
      }

      await _notificationService.scheduleBookingReminder(
        id: bookingIdNum,
        serviceName: serviceName,
        bookingTime: scheduledDateTime,
      );

      final newBooking = BookingModel(
        bookingId: "BKG-$bookingIdNum",
        serviceName: serviceName,
        stylistName: stylistName,
        bookingDateTime: scheduledDateTime,
        price: price,
        status: 'Confirmed',
        googleCalendarEventId: eventId,
      );

      _bookings.add(newBooking);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error saat createBooking: $e");
      return false;
    }
  }

  // Fitur Batal / Hapus Booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final index = _bookings.indexWhere((item) => item.bookingId == bookingId);
      if (index == -1) return false;

      final targetBooking = _bookings[index];

      // 1. Hapus dari Google Calendar jika ada event ID-nya
      if (targetBooking.googleCalendarEventId != null) {
        await _calendarService.deleteBookingEvent(targetBooking.googleCalendarEventId!);
      }

      // 2. Batalkan jadwal pengingat notifikasi lokal
      final rawIdString = bookingId.replaceFirst('BKG-', '');
      final notifId = int.tryParse(rawIdString);
      if (notifId != null) {
        await _notificationService.cancelNotification(notifId);
      }

      // 3. Opsi A: Hapus langsung dari daftar riwayat
      _bookings.removeAt(index);

      // Opsi B: Jika ingin statusnya berubah jadi 'Cancelled' tanpa dihapus, gunakan ini:
      // _bookings[index] = BookingModel(
      //   bookingId: targetBooking.bookingId,
      //   serviceName: targetBooking.serviceName,
      //   stylistName: targetBooking.stylistName,
      //   bookingDateTime: targetBooking.bookingDateTime,
      //   price: targetBooking.price,
      //   status: 'Cancelled',
      //   googleCalendarEventId: null,
      // );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error saat cancelBooking: $e");
      return false;
    }
  }
}