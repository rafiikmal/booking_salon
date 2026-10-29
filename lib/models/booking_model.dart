class BookingModel {
  final String bookingId;
  final String serviceName;
  final String stylistName;
  final DateTime bookingDateTime;
  final double price;
  final String status;
  final String? googleCalendarEventId;

  BookingModel({
    required this.bookingId,
    required this.serviceName,
    required this.stylistName,
    required this.bookingDateTime,
    required this.price,
    required this.status,
    this.googleCalendarEventId,
  });
}