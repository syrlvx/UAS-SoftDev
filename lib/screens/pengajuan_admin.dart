import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PengajuanAdminScreen extends StatefulWidget {
  @override
  _PengajuanAdminScreenState createState() => _PengajuanAdminScreenState();
}

class _PengajuanAdminScreenState extends State<PengajuanAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors
                .transparent, // Transparent untuk memungkinkan background gradasi
            automaticallyImplyLeading: false, // Disable the back button
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF001F3D), // Biru navy
                    Color(0xFF001F3D)
                        .withOpacity(0.8), // Biru navy lebih gelap di bawah
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "Cuti"),
                Tab(text: "Izin"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            PengajuanList(jenis: 'cuti'),
            PengajuanList(jenis: 'izin'),
          ],
        ),
      ),
    );
  }
}

Future<void> sendOneSignalNotification(
    String playerId, String title, String message) async {
  var response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'Basic os_v2_app_6fpbl7nmavh2rigyk3jckrvdz4npvshcwv5uurfnwf56fscssigsmu57npipetjzfxniautukvwg6c3ssklqfduu7cvfue3qgynbzoa',
    },
    body: jsonEncode({
      'app_id': 'f15e15fd-ac05-4fa8-a0d8-56d22546a3cf',
      'include_player_ids': [playerId],
      'headings': {'en': title},
      'contents': {'en': message},
    }),
  );
  print(response.body);
}

class PengajuanList extends StatefulWidget {
  final String jenis;
  const PengajuanList({required this.jenis});

  @override
  _PengajuanListState createState() => _PengajuanListState();
}

class _PengajuanListState extends State<PengajuanList> {
  Future<void> updateStatus(String docId, String status) async {
    try {
      print('Starting status update for document: $docId');

      // Update status in Firestore
      await FirebaseFirestore.instance
          .collection('pengajuan')
          .doc(docId)
          .update({'status': status});
      print('Status updated in Firestore');

      // Get the document data
      final doc = await FirebaseFirestore.instance
          .collection('pengajuan')
          .doc(docId)
          .get();
      print('Retrieved document data');

      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'];
      final jenis = data['jenis'];
      final nama = data['nama'];
      print('Document data - userId: $userId, jenis: $jenis, nama: $nama');

      // Get user's OneSignal playerId
      final userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      print('Retrieved user document');

      final playerId = userDoc.data()?['onesignalPlayerId'];
      print('PlayerId: $playerId');

      // Create notification data with more detailed message
      String title = 'Status Pengajuan ${jenis.toUpperCase()}';
      String message =
          'Pengajuan ${jenis.toUpperCase()} dari $nama telah $status';
      print('Created notification - Title: $title, Message: $message');

      // Save notification to Firestore with more details
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'category': 'pengajuan',
        'read': false,
        'archived': false,
        'jenis': jenis,
        'status': status,
        'nama': nama,
      });
      print('Notification saved to Firestore');

      // Send OneSignal notification with improved error handling
      if (playerId != null && playerId.isNotEmpty) {
        try {
          print('Attempting to send OneSignal notification...');
          await sendOneSignalNotification(playerId, title, message);
          print('OneSignal notification sent successfully');
        } catch (e) {
          print('Error sending OneSignal notification: $e');
          print('Error details: ${e.toString()}');
        }
      } else {
        print('No valid playerId found for user $userId');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error in updateStatus: $e');
      print('Error details: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengajuan')
          .where('jenis', isEqualTo: widget.jenis)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Tidak ada pengajuan ${widget.jenis}'));
        }

        // Sort documents by tanggal in descending order
        final sortedDocs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = (aData['tanggal'] as Timestamp).toDate();
            final bDate = (bData['tanggal'] as Timestamp).toDate();
            return bDate.compareTo(aDate); // Descending order
          });

        return ListView.builder(
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final doc = sortedDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      data['nama'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tanggal: ${(data['tanggal'] as Timestamp).toDate().toString().split(' ')[0]}",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        if (widget.jenis == 'cuti') ...[
                          Text(
                            "Link File: ${data['linkFile'] ?? '-'}",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                        ] else ...[
                          Text(
                            "Keterangan: ${data['keterangan'] ?? '-'}",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                        ],
                        Text(
                          "Status: $status",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                    actions: [
                      if (status == 'Pending') ...[
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            Navigator.pop(context);
                            updateStatus(doc.id, 'Disetujui');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            updateStatus(doc.id, 'Ditolak');
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListTile(
                  leading: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('user')
                        .doc(data['userId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final photoUrl = userData['foto'];

                        return CircleAvatar(
                          backgroundColor: Color(0xFF001F3D),
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  (data['nama'] as String).isNotEmpty
                                      ? (data['nama'] as String)[0]
                                          .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              : null,
                        );
                      }
                      return CircleAvatar(
                        backgroundColor: Color(0xFF001F3D),
                        child: Text(
                          (data['nama'] as String).isNotEmpty
                              ? (data['nama'] as String)[0].toUpperCase()
                              : '?',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                  title: Text(
                    data['nama'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.jenis == 'cuti')
                        Text(
                          "Link File: ${data['linkFile'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        )
                      else
                        Text(
                          "Keterangan: ${data['keterangan'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      Text(
                        "Tanggal: ${(data['tanggal'] as Timestamp).toDate().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'Pending'
                          ? Colors.orange
                          : status == 'Disetujui'
                              ? Colors.green
                              : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
