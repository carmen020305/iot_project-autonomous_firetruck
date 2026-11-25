import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  void sendDirection(String direction) {
    FirebaseFirestore.instance.collection('commands').doc('robot').set({
      'direction': direction,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void sendPump(bool pumpOn) {
    FirebaseFirestore.instance.collection('commands').doc('robot').set({
      'pump': pumpOn,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void sendMode(bool auto) {
    FirebaseFirestore.instance.collection('commands').doc('robot').set({
      'mode': auto ? 'auto' : 'manual',
      'direction': 'stop',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Widget directionButton(String label, String direction, bool enabled) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 150,
        height: 80,
        child: ElevatedButton(
          onPressed: enabled ? () => sendDirection(direction) : null,
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commands')
            .doc('robot')
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final bool autoMode = data?['mode'] == 'auto';
          final bool manual = !autoMode;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('status')
                    .doc('robot')
                    .snapshots(),
                builder: (context, statusSnapshot) {
                  final statusData =
                      statusSnapshot.data?.data() as Map<String, dynamic>?;
                  final String message =
                      statusData?['message']?.toString() ?? 'No message yet';

                  return Container(
                    width: 420,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Automatic mode',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: autoMode,
                      onChanged: (value) => sendMode(value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                directionButton('Forward', 'forward', manual),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    directionButton('Left', 'left', manual),
                    directionButton('Stop', 'stop', manual),
                    directionButton('Right', 'right', manual),
                  ],
                ),
                directionButton('Backward', 'backward', manual),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: manual ? () => sendPump(true) : null,
                        child: const Text(
                          'Pump on',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: manual ? () => sendPump(false) : null,
                        child: const Text(
                          'Pump off',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
