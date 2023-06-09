import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teeth_kids_flutter/dentists_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/take_pictures_pic.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 200,
                ),
                Column(children: [
                  const Text(
                    'Tire 3 fotos da boca da criança',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 80,
                        ),
                        onPressed: () async {
                          final cameras = await availableCameras();
                          final firstCamera = cameras.first;
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreen(camera: firstCamera)),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 80,
                        ),
                        onPressed: () async {
                          final cameras = await availableCameras();
                          final firstCamera = cameras.first;
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreen(camera: firstCamera)),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 80,
                        ),
                        onPressed: () async {
                          final cameras = await availableCameras();
                          final firstCamera = cameras.first;
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreen(camera: firstCamera)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Numero do Telefone',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Aumentar o tamanho da fonte
                        ),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final String phoneNumber = _phoneNumberController.text;
                        final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

                        // Adicione o ID e o número de telefone à coleção 'emergency_requests'
                        FirebaseFirestore.instance.collection('emergency_requests').add({
                          'userId': userId,
                          'phoneNumber': phoneNumber,
                        }).then((value) {
                          // Sucesso ao adicionar à coleção
                          print('Dados adicionados com sucesso');
                        }).catchError((error) {
                          // Erro ao adicionar à coleção
                          print('Erro ao adicionar dados: $error');
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DentistsList()),
                        );
                      },
                      child: const Text('Acionar emergência'),
                    ),

                  ],
                ),
              ),
            ),
          )


          ,
        ],
      ),
    );
  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tire a foto')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final String imagePath;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto pronta')),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          ElevatedButton(
            onPressed: () {
              uploadImageToFirebase();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> uploadImageToFirebase() async {
    File imageFile = File(imagePath);
    String fileName = path.basename(imageFile.path);
    try {
      await storage.ref().child('users/$userId/$fileName').putFile(imageFile);
    } catch (e) {
      print(e.toString());
    }
  }
}
