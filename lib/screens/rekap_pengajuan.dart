import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RekapPengajuanScreen extends StatefulWidget {
  const RekapPengajuanScreen({super.key});

  @override
  State<RekapPengajuanScreen> createState() => _RekapPengajuanScreenState();
}

class _RekapPengajuanScreenState extends State<RekapPengajuanScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> pengajuanList = [];

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  Future<void> _loadPengajuan() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No user logged in');
        return;
      }

      print('DEBUG: Loading pengajuan for user: ${user.uid}');
      print('DEBUG: User email: ${user.email}');

      // Get all documents and filter on client side
      final querySnapshot =
          await FirebaseFirestore.instance.collection('pengajuan').get();

      print(
          'DEBUG: Total documents in collection: ${querySnapshot.docs.length}');

      // Filter documents for current user
      final userDocuments = querySnapshot.docs.where((doc) {
        final data = doc.data();
        return data['userId'] == user.uid;
      }).toList();

      print(
          'DEBUG: Found ${userDocuments.length} documents for user ${user.uid}');

      if (userDocuments.isEmpty) {
        print('DEBUG: No documents found for this user');
        setState(() {
          pengajuanList = [];
          isLoading = false;
        });
        return;
      }

      // Sort documents by createdAt
      userDocuments.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aDate = aData['createdAt'] as Timestamp?;
        final bDate = bData['createdAt'] as Timestamp?;

        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate); // descending order
      });

      setState(() {
        pengajuanList = userDocuments.map((doc) {
          final data = doc.data();
          print('DEBUG: Processing document ${doc.id}:');
          print('DEBUG: - jenis: ${data['jenis']}');
          print('DEBUG: - status: ${data['status']}');
          print('DEBUG: - tanggal: ${data['tanggal']}');
          print('DEBUG: - nama: ${data['nama']}');
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        isLoading = false;
      });

      print('DEBUG: Final pengajuanList length: ${pengajuanList.length}');
    } catch (e, stackTrace) {
      print('DEBUG: Error loading pengajuan: $e');
      print('DEBUG: Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deletePengajuan(String pengajuanId) async {
    try {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Konfirmasi Hapus',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus pengajuan ini?',
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Delete the document
      await FirebaseFirestore.instance
          .collection('pengajuan')
          .doc(pengajuanId)
          .delete();

      // Remove loading indicator
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload the list
      _loadPengajuan();
    } catch (e) {
      // Remove loading indicator if it's showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pengajuan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Rekap Pengajuan'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pengajuanList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data pengajuan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pengajuanList.length,
                  itemBuilder: (context, index) {
                    final pengajuan = pengajuanList[index];
                    final tanggal =
                        (pengajuan['tanggal'] as Timestamp).toDate();
                    final formattedDate =
                        DateFormat('dd-MM-yyyy').format(tanggal);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IzinCard(
                        id: pengajuan['id'],
                        type: pengajuan['jenis']?.toString().toUpperCase() ??
                            'Unknown',
                        status: pengajuan['status'] ?? 'Pending',
                        statusDate: formattedDate,
                        name: pengajuan['nama'] ?? 'Unknown',
                        startDate: formattedDate,
                        endDate: formattedDate,
                        description: pengajuan['keterangan'] ??
                            pengajuan['linkFile'] ??
                            'Tidak ada keterangan',
                        onDelete: _deletePengajuan,
                      ),
                    );
                  },
                ),
    );
  }
}

class IzinCard extends StatelessWidget {
  final String id;
  final String type, status, statusDate, name, startDate, endDate, description;
  final Function(String) onDelete;

  const IzinCard({
    super.key,
    required this.id,
    required this.type,
    required this.status,
    required this.statusDate,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.onDelete,
  });

  Color _typeColor() {
    switch (type.toLowerCase()) {
      case 'izin':
        return const Color.fromARGB(255, 200, 106, 13);
      case 'cuti':
        return const Color.fromARGB(255, 13, 96, 13);
      default:
        return Colors.grey;
    }
  }

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'disetujui':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Jenis & Status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _statusIcon(),
                  size: 15,
                  color: _statusColor(),
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(),
                      ),
                    ),
                    Text(
                      statusDate,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _statusColor(),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete(id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Oleh $name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Mulai : ',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 13,
                  ),
                ),
                Text(
                  startDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Selesai : ',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
                Text(
                  endDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Keterangan: ',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: description,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
