import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ratings extends StatefulWidget {
  final String dentistID;

  const Ratings({super.key, required this.dentistID});

  @override
  State<Ratings> createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  double _rating = 0.0;
  String _comment = '';
  double _appRating = 0.0;
  String _appComment = '';

  void _rate(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _saveComment(String comment) {
    setState(() {
      _comment = comment;
    });
  }

  void _saveAppRating(double rating) {
    setState(() {
      _appRating = rating;
    });
  }

  void _saveAppComment(String comment) {
    setState(() {
      _appComment = comment;
    });
  }

  Future<void> _sendRating() async {
    // Salvar a avaliação do dentista no Firestore
    await FirebaseFirestore.instance
        .collection('dentists_ratings')
        .doc(widget.dentistID)
        .collection('ratings')
        .add({
      'rating': _rating,
      'comment': _comment,
    });

    // Salvar a avaliação do aplicativo no Firestore
    await FirebaseFirestore.instance.collection('app_ratings').add({
      'rating': _appRating,
      'comment': _appComment,
    });

    // Voltar para a página inicial
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação de Atendimento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Como foi o atendimento?',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  double ratingValue = index + 1;
                  return IconButton(
                    onPressed: () => _rate(ratingValue),
                    icon: Icon(
                      Icons.star,
                      color:
                          _rating >= ratingValue ? Colors.yellow : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Escreva sobre como foi o atendimento:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              TextField(
                onChanged: _saveComment,
                decoration: const InputDecoration(
                  hintText: 'Digite seu comentário',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Avalie o aplicativo:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  double ratingValue = index + 1;
                  return IconButton(
                    onPressed: () => _saveAppRating(ratingValue),
                    icon: Icon(
                      Icons.star,
                      color: _appRating >= ratingValue
                          ? Colors.yellow
                          : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Comentário sobre o aplicativo:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              TextField(
                onChanged: _saveAppComment,
                decoration: const InputDecoration(
                  hintText: 'Digite seu comentário',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _rating > 0 &&
                        _comment.isNotEmpty &&
                        _appRating > 0 &&
                        _appComment.isNotEmpty
                    ? _sendRating
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
