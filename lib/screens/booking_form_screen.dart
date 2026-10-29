import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booking_salon/providers/booking_provider.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  const BookingFormScreen({super.key, required this.serviceData});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedStylist;
  String? _selectedTime;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _syncCalendar = true;
  bool _isLoading = false;

  final List<String> _stylists = ['Sarah (Stylist)', 'Rian (Hair Terapist)', 'Maya (Colorist)'];
  final List<String> _timeSlots = ['10:00', '11:30', '13:00', '14:30', '16:00'];

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStylist == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap tentukan Stylist dan Jam kunjungan!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await context.read<BookingProvider>().createBooking(
      serviceName: widget.serviceData['title'],
      stylistName: _selectedStylist!,
      date: _selectedDate,
      timeSlot: _selectedTime!,
      durationMinutes: widget.serviceData['durationMinutes'] ?? 60,
      price: widget.serviceData['priceValue'] ?? 100000.0,
      syncToCalendar: _syncCalendar,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Reservasi Berhasil!'),
          content: const Text(
            'Jadwal telah tersimpan, pengingat telah diset, dan kalender telah disinkronkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking: ${widget.serviceData['title']}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp / HP',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().length < 10
                  ? 'Nomor telepon minimal 10 digit'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Stylist',
                border: OutlineInputBorder(),
              ),
              items: _stylists.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedStylist = val),
              validator: (val) => val == null ? 'Silakan pilih stylist' : null,
            ),
            const SizedBox(height: 20),
            const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 20),
            const Text('Pilih Slot Jam', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: _selectedTime == time,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTime = time);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sinkron ke Google Calendar'),
              subtitle: const Text('Otomatis catat jadwal ke akun Google Anda'),
              value: _syncCalendar,
              onChanged: (val) => setState(() => _syncCalendar = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: _submitBooking,
              child: const Text('Konfirmasi Pemesanan', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}