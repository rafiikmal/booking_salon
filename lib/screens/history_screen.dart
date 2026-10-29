import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booking_salon/providers/booking_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.bookings;

    if (bookings.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Belum ada riwayat booking')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Booking')),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(booking.serviceName),
              subtitle: Text(
                'Stylist: ${booking.stylistName}\n${booking.bookingDateTime}',
              ),

              // TARUH KODE ICONBUTTON DI SINI
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Batalkan Booking?'),
                      content: const Text(
                        'Jadwal ini akan dibatalkan dan dihapus otomatis dari Google Calendar.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            Navigator.pop(ctx);

                            final success = await context
                                .read<BookingProvider>()
                                .cancelBooking(booking.bookingId);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Booking berhasil dibatalkan!'
                                        : 'Gagal membatalkan booking.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}