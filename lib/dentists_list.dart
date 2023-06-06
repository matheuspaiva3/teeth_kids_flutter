import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maps.dart';

class DentistsList extends StatefulWidget {
  const DentistsList({super.key});

  @override
  State<DentistsList> createState() => _DentistsListState();
}

class _DentistsListState extends State<DentistsList> {
  final _userStream = FirebaseFirestore.instance
      .collection('users')
      .where('isActive', isEqualTo: true)
      .limit(5)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFacbeff),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6153ff),
        centerTitle: true,
        title: const Text('Dentistas disponíveis'),
      ),
      body: StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Connection error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Carregando...');
          }

          var docs = snapshot.data!.docs;
          //return Text('${docs.length}');
          return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(docs[index]['name']),
                  trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () async {
                        if (docs[index]['email'] != null) {
                          String? uid =
                              await getUIDFromFirestore(docs[index]['email']);
                          if (uid != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Map(dentistID: uid),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      label: const Text(
                          style: TextStyle(color: Colors.white), 'Aceitar')),
                );
              });
        },
      ),
    );
  }
}

Future<String?> getUIDFromFirestore(String email) async {
  // Query the "users" collection in Firestore based on the email
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  // Check if a matching document is found
  if (snapshot.size > 0) {
    // Retrieve the first document snapshot
    final docSnapshot = snapshot.docs[0];

    String uid = docSnapshot.id;
    return uid;
  }
  return null;
}
