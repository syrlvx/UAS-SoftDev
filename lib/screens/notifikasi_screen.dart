import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> archivedNotifications = [];
  String selectedFilter = 'Semua';
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'body': data['message'] ?? '',
          'time': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp)
                  .toDate()
                  .toString()
                  .split(' ')[1]
                  .substring(0, 5)
              : '',
          'datetime': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'category': data['category'] ?? 'pengajuan',
          'read': data['read'] ?? false,
          'archived': data['archived'] ?? false,
        };
      }).toList();

      // Sort notifications by datetime
      notifications.sort((a, b) => b['datetime'].compareTo(a['datetime']));
    });
  }

  void markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();

    for (var notif in notifications) {
      if (!notif['read']) {
        final docRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(notif['id']);
        batch.update(docRef, {'read': true});
      }
    }

    await batch.commit();
    await _loadNotifications();
  }

  void removeNotification(int index) async {
    final notif = notifications[index];
    final notifData = {
      'id': notif['id'],
      'title': notif['title'],
      'message': notif['body'],
      'createdAt': notif['datetime'] is DateTime
          ? Timestamp.fromDate(notif['datetime'])
          : Timestamp.fromDate(DateTime.now()),
      'category': notif['category'],
      'read': notif['read'],
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'archived': false,
    };

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notif['id'])
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Notifikasi dihapus"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(notif['id'])
                  .set(notifData);
              await _loadNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Notifikasi berhasil dikembalikan")),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Gagal mengembalikan notifikasi")),
                );
              }
            }
          },
        ),
      ),
    );
    await _loadNotifications();
  }

  void archiveNotification(int index) async {
    final notif = notifications[index];
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notif['id'])
        .update({'archived': true});

    setState(() {
      archivedNotifications.add(notif);
      notifications.removeAt(index);
    });
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compare = DateTime(date.year, date.month, date.day);
    if (compare == today) return 'Hari ini';
    if (compare == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = notifications.where((n) {
      if (selectedFilter == 'Semua') return true;
      if (selectedFilter == 'Belum dibaca') return !n['read'];
      return n['category'] == selectedFilter.toLowerCase();
    }).toList();

    filtered.sort((a, b) => sortAscending
        ? a['datetime'].compareTo(b['datetime'])
        : b['datetime'].compareTo(a['datetime']));

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var notif in filtered) {
      String label = getDateLabel(notif['datetime']);
      grouped.putIfAbsent(label, () => []).add(notif);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Tinggi AppBar
        child: AppBar(
          title: const Text(
            'Notifikasi',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F3D), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
          children: [
            // Filter dan sort
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // KIRI: Sort
                PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort,
                        color: Color.fromARGB(255, 127, 157, 195),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sortAscending ? 'Terlama' : 'Terbaru',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 127, 157, 195),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  offset: const Offset(0, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.white,
                  elevation: 4,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Terbaru',
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: !sortAscending
                                ? const Color.fromARGB(255, 127, 157, 195)
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Terbaru',
                            style: GoogleFonts.poppins(
                              color: !sortAscending
                                  ? const Color.fromARGB(255, 127, 157, 195)
                                  : Colors.grey,
                              fontWeight: !sortAscending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Terlama',
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: sortAscending
                                ? const Color.fromARGB(255, 127, 157, 195)
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Terlama',
                            style: GoogleFonts.poppins(
                              color: sortAscending
                                  ? const Color.fromARGB(255, 127, 157, 195)
                                  : Colors.grey,
                              fontWeight: sortAscending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (mounted) {
                      setState(() {
                        sortAscending = (value == 'Terlama');
                      });
                    }
                  },
                ),
                const SizedBox(width: 130),
                // KANAN: Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color.fromARGB(255, 127, 157, 195),
                        width: 1,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: selectedFilter,
                      offset: const Offset(0, 40),
                      onSelected: (String newValue) {
                        setState(() {
                          selectedFilter = newValue;
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        'Semua',
                        'Pengajuan',
                        'Tugas',
                      ].map((String value) {
                        return PopupMenuItem<String>(
                          value: value,
                          height: 35,
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 127, 157, 195),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                selectedFilter,
                                style: GoogleFonts.poppins(
                                  color:
                                      const Color.fromARGB(255, 127, 157, 195),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromARGB(255, 127, 157, 195),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List Notifikasi
            ...grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ...entry.value.map((notif) {
                    int index = notifications.indexOf(notif);
                    return Dismissible(
                      key: Key(notif['id']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        removeNotification(index);
                      },
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.grey.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: Icon(
                            notif['category'] == 'pengajuan'
                                ? Icons.send
                                : notif['category'] == 'tugas'
                                    ? Icons.assignment
                                    : Icons.notifications_active,
                            color: const Color(0xFF001F3D),
                          ),
                          title: Text(
                            notif['title'],
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            notif['body'],
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notif['time'],
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (!notif['read']) {
                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(notif['id'])
                                  .update({'read': true});
                              await _loadNotifications();
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
