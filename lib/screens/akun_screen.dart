import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun Saya'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email}'),
                      SizedBox(height: 10),
                      Text('UID: ${user.uid}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Logout'),
                      ),
                    ],
                  )
                : Center(child: Text('Tidak ada data akun')),
          ],
        ),
      ),
    );
  }
}
