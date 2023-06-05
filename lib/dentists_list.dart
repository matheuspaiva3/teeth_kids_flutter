import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maps.dart';

class DentistsList extends StatefulWidget {
  const DentistsList({super.key});

  @override
  State<DentistsList> createState() => _DentistsListState();
}

class _DentistsListState extends State<DentistsList> {
  final _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();

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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Map()));
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
