import 'package:flutter/material.dart';
import 'package:purelux/screens/arsip_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Pengajuan cuti diterima',
      'body': 'Cuti tanggal 10-12 disetujui.',
      'time': '10:00',
      'category': 'pengajuan',
      'read': false,
      'datetime': DateTime.now(),
      'archived': false
    },
    {
      'title': 'Reminder Tugas',
      'body': 'Kerjakan tugas harian',
      'time': '09:00',
      'category': 'tugas',
      'read': false,
      'datetime': DateTime.now().subtract(Duration(days: 1)),
      'archived': false
    },
    {
      'title': 'Notifikasi umum',
      'body': 'Sistem update berhasil',
      'time': '08:00',
      'category': 'lainnya',
      'read': true,
      'datetime': DateTime.now().subtract(Duration(days: 2)),
      'archived': false
    },
  ];

  List<Map<String, dynamic>> archivedNotifications = [];

  String selectedFilter = 'Semua';
  String selectedSort = 'Terbaru ke Lama';

  void markAllAsRead() {
    setState(() {
      for (var notif in notifications) {
        notif['read'] = true;
      }
    });
  }

  void removeNotification(int index) {
    final removed = notifications.removeAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Notifikasi dihapus"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              notifications.insert(index, removed);
            });
          },
        ),
      ),
    );
    setState(() {});
  }

  void archiveNotification(int index) {
    setState(() {
      var notif = notifications[index];
      notif['archived'] = true;
      archivedNotifications.add(notif);
      notifications.removeAt(index);
    });
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compare = DateTime(date.year, date.month, date.day);
    if (compare == today) return 'Hari ini';
    if (compare == today.subtract(Duration(days: 1))) return 'Kemarin';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Filter
    List<Map<String, dynamic>> filtered = notifications.where((n) {
      if (selectedFilter == 'Semua') return true;
      if (selectedFilter == 'Belum dibaca') return !n['read'];
      return n['category'] == selectedFilter.toLowerCase();
    }).toList();

    // Sort
    filtered.sort((a, b) => selectedSort == 'Terbaru ke Lama'
        ? b['datetime'].compareTo(a['datetime'])
        : a['datetime'].compareTo(b['datetime']));

    // Group by date
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var notif in filtered) {
      String label = getDateLabel(notif['datetime']);
      grouped.putIfAbsent(label, () => []).add(notif);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title:
              const Text('Notifikasi', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.archive, color: Colors.white),
              tooltip: 'Lihat Arsip',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArchivedNotificationsScreen(
                      archivedNotifications: archivedNotifications,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: markAllAsRead,
        icon: Icon(Icons.done_all),
        label: Text("Tandai semua dibaca"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sort Dropdown
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    // Hapus bagian decoration agar kotak border hilang
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSort,
                        dropdownColor: Colors.white,
                        style: TextStyle(color: Colors.black),
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down,
                            size: 16, color: Colors.grey), // segitiga kecil abu
                        onChanged: (val) {
                          setState(() => selectedSort = val!);
                        },
                        selectedItemBuilder: (context) {
                          return ['Terbaru ke Lama', 'Lama ke Terbaru']
                              .map((e) {
                            IconData iconData = e == 'Terbaru ke Lama'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward;
                            return Row(
                              children: [
                                Icon(iconData, color: Colors.black, size: 18),
                                SizedBox(width: 6),
                                Text(e, style: TextStyle(color: Colors.black)),
                              ],
                            );
                          }).toList();
                        },
                        items: ['Terbaru ke Lama', 'Lama ke Terbaru'].map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child:
                                Text(e, style: TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16), // Jarak antar dropdown

                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        dropdownColor: Colors.white,
                        style: TextStyle(color: Colors.black),
                        isExpanded: true,
                        icon: SizedBox
                            .shrink(), // Hilangkan panah segitiga default
                        onChanged: (val) {
                          setState(() {
                            selectedFilter = val!;
                          });
                        },
                        selectedItemBuilder: (context) {
                          return ['Semua', 'Belum dibaca', 'Pengajuan', 'Tugas']
                              .map((e) {
                            return Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end, // Rata kanan
                              children: [
                                Icon(Icons.arrow_drop_down,
                                    color: Colors.black, size: 16),
                                SizedBox(
                                    width: 6), // Jarak antara teks dan ikon
                                Text(e, style: TextStyle(color: Colors.black)),
                                SizedBox(
                                    width: 6), // Jarak antara teks dan panah

                                Icon(Icons.filter_alt_outlined,
                                    color:
                                        Colors.black), // Ikon di kanan // Panah
                              ],
                            );
                          }).toList();
                        },
                        items: ['Semua', 'Belum dibaca', 'Pengajuan', 'Tugas']
                            .map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end, // Rata kanan
                              children: [
                                Text(e, style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            ...grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...entry.value.asMap().entries.map((e) {
                    int index = notifications.indexOf(e.value);
                    var notif = e.value;
                    return Dismissible(
                      key: Key(notif['title'] + notif['time']),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          removeNotification(index);
                        } else if (direction == DismissDirection.startToEnd) {
                          archiveNotification(index);
                        }
                      },
                      background: Container(
                        color: Colors.orangeAccent,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.archive, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(
                            notif['category'] == 'pengajuan'
                                ? Icons.send
                                : notif['category'] == 'tugas'
                                    ? Icons.assignment
                                    : Icons.notifications_active,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            notif['title'],
                            style: TextStyle(
                              fontWeight: notif['read']
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(notif['body']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(notif['time'],
                                  style: TextStyle(fontSize: 12)),
                              if (!notif['read'])
                                Icon(Icons.circle, size: 10, color: Colors.red)
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              notif['read'] = true;
                            });
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
