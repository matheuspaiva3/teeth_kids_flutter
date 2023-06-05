import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListaDentistas extends StatefulWidget {
  const ListaDentistas({super.key});

  @override
  State<ListaDentistas> createState() => _ListaDentistasState();
}

class _ListaDentistasState extends State<ListaDentistas> {
  final _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFacbeff),
      appBar: AppBar(
        backgroundColor: Color(0xFF6153ff),
        centerTitle: true,
        title: Text('Dentistas disponíveis'),
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
                  leading: Icon(Icons.person),
                  title: Text(docs[index]['name']),
                  trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {},
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
