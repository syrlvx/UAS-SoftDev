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
      'title': 'Pengajuan Cuti',
      'body': 'Cuti tanggal 10 Mei disetujui',
      'time': '10:00',
      'datetime': DateTime.now(),
      'category': 'pengajuan',
      'read': false,
      'archived': false,
    },
    {
      'title': 'Tugas Baru',
      'body': 'Isi laporan mingguan',
      'time': '09:00',
      'datetime': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'tugas',
      'read': false,
      'archived': false,
    },
  ];

  List<Map<String, dynamic>> archivedNotifications = [];
  String selectedFilter = 'Semua';
  bool sortAscending = false;

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
        content: const Text("Notifikasi dihapus"),
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
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF001F3D), // Biru navy gelap
                Color(0xFFFFFFFF)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: markAllAsRead,
        icon: const Icon(Icons.done_all, color: Colors.white),
        label: const Text(
          "Tandai semua dibaca",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF001F3D), // warna navy
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 100, 12, 12),
          children: [
            // Filter dan sort
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 20, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(
                        sortAscending ? 'Terlama' : 'Terbaru',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'Terbaru', child: Text('Terbaru')),
                    const PopupMenuItem(
                        value: 'Terlama', child: Text('Terlama')),
                  ],
                  onSelected: (value) {
                    setState(() {
                      sortAscending = (value == 'Terlama');
                    });
                  },
                ),
                const SizedBox(width: 170),
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
                        'Belum dibaca',
                        'Pengajuan',
                        'Tugas',
                      ].map((String value) {
                        return PopupMenuItem<String>(
                          value: value,
                          height: 35,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 127, 157, 195),
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
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 127, 157, 195),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ...entry.value.map((notif) {
                    int index = notifications.indexOf(notif);
                    return Dismissible(
                      key: Key(notif['title'] + notif['time']),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          removeNotification(index);
                        } else {
                          archiveNotification(index);
                        }
                      },
                      background: Container(
                        color: Colors.orangeAccent,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.archive, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 2, // tanpa bayangan
                        shadowColor: Colors.grey.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.grey.shade300), // garis tipis
                        ),
                        child: ListTile(
                          leading: Icon(
                            notif['category'] == 'pengajuan'
                                ? Icons.send
                                : notif['category'] == 'tugas'
                                    ? Icons.assignment
                                    : Icons.notifications_active,
                            color: Color(0xFF001F3D),
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
                                  style: const TextStyle(fontSize: 12)),
                              if (!notif['read'])
                                const Icon(Icons.circle,
                                    size: 10, color: Colors.red),
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
