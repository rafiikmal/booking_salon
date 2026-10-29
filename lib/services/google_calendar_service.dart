import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleCalendarService {
  static const String _webClientId =
      '1063098615711-4ok8ci0cgbpdb9ncso1hgmkj010259il.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      calendar.CalendarApi.calendarEventsScope,
    ],
  );

  GoogleSignInAccount? currentUser;

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      currentUser = account;
      return account != null;
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    currentUser = null;
  }

  // Tambah event
  Future<String?> addBookingEvent({
    required String serviceTitle,
    required String stylistName,
    required DateTime startDateTime,
    required int durationMinutes,
  }) async {
    try {
      if (currentUser == null) {
        final loggedIn = await signIn();
        if (!loggedIn) return null;
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return null;

      final calendarApi = calendar.CalendarApi(authClient);
      final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

      final event = calendar.Event(
        summary: 'Booking Salon - $serviceTitle',
        description: 'Layanan: $serviceTitle\nStylist: $stylistName',
        start: calendar.EventDateTime(
          dateTime: startDateTime,
          timeZone: 'Asia/Jakarta',
        ),
        end: calendar.EventDateTime(
          dateTime: endDateTime,
          timeZone: 'Asia/Jakarta',
        ),
      );

      final createdEvent = await calendarApi.events.insert(event, 'primary');
      debugPrint('Event Google Calendar berhasil dibuat: ${createdEvent.id}');
      return createdEvent.id;
    } catch (e) {
      debugPrint('Error saat membuat event di Calendar: $e');
      return null;
    }
  }

  // Hapus event dari Google Calendar
  Future<bool> deleteBookingEvent(String eventId) async {
    try {
      if (currentUser == null) {
        final loggedIn = await signIn();
        if (!loggedIn) return false;
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return false;

      final calendarApi = calendar.CalendarApi(authClient);
      await calendarApi.events.delete('primary', eventId);
      debugPrint('Event Google Calendar $eventId berhasil dihapus');
      return true;
    } catch (e) {
      debugPrint('Error saat menghapus event dari Calendar: $e');
      return false;
    }
  }
}