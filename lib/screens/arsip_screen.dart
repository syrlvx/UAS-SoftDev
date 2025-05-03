import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArchivedNotificationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> archivedNotifications;

  const ArchivedNotificationsScreen(
      {Key? key, required this.archivedNotifications})
      : super(key: key);

  @override
  State<ArchivedNotificationsScreen> createState() =>
      _ArchivedNotificationsScreenState();
}

class _ArchivedNotificationsScreenState
    extends State<ArchivedNotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;
  bool _isPinSet = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notifications = widget.archivedNotifications;
    _checkIfPinExists();
  }

  // Cek apakah PIN sudah ada di SharedPreferences
  Future<void> _checkIfPinExists() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('pin');
    setState(() {
      _isPinSet = pin != null && pin.isNotEmpty;
    });

    if (!_isPinSet) {
      // Jika PIN belum ada, tampilkan dialog untuk memasukkan PIN
      _showPinDialog();
    }
  }

  // Menyimpan PIN ke SharedPreferences
  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin', pin);
  }

  // Verifikasi PIN yang dimasukkan
  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('pin');
    if (_pinController.text == storedPin) {
      setState(() {
        _isPinSet = true;
      });
      Navigator.of(context).pop(); // Menutup dialog jika PIN benar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN berhasil diverifikasi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN salah, coba lagi')),
      );
    }
  }

  // Menampilkan dialog untuk memasukkan PIN pertama kali
  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Membuat dialog tidak bisa ditutup sembarangan
      builder: (context) {
        return AlertDialog(
          title: Text('Set PIN'),
          content: TextField(
            controller: _pinController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Masukkan PIN baru'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_pinController.text.isNotEmpty) {
                  _savePin(_pinController.text);
                  setState(() {
                    _isPinSet = true;
                  });
                  Navigator.of(context)
                      .pop(); // Menutup dialog setelah PIN diset
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PIN berhasil diset')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk memasukkan PIN jika sudah ada
  void _showPinVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan PIN'),
          content: TextField(
            controller: _pinController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Masukkan PIN'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: _verifyPin,
              child: Text('Verifikasi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arsip Notifikasi'),
      ),
      body: _isPinSet
          ? _notifications.isEmpty
              ? Center(child: Text('Tidak ada notifikasi yang diarsipkan.'))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    var notif = _notifications[index];
                    return Card(
                      child: ListTile(
                        title: Text(notif['title'] ?? ''),
                        subtitle: Text(notif['body'] ?? ''),
                      ),
                    );
                  },
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
