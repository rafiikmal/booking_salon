import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booking_salon/theme/app_theme.dart';
import 'package:booking_salon/providers/booking_provider.dart';
import 'package:booking_salon/services/notification_service.dart';
import 'package:booking_salon/screens/login_screen.dart';
import 'package:booking_salon/screens/main_navigation_screen.dart';
import 'package:booking_salon/screens/booking_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const SalonApp(),
    ),
  );
}

class SalonApp extends StatelessWidget {
  const SalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Awal aplikasi diarahkan ke LoginScreen
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        // Rute untuk layar utama pengguna (dengan navbar Layanan & Riwayat)
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
        }
        // Rute untuk form pemesanan
        if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BookingFormScreen(serviceData: args),
          );
        }
        return null;
      },
    );
  }
}