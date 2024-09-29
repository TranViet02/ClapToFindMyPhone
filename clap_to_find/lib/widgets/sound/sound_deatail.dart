// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SoundDetailScreen extends StatefulWidget {
//   final String imagePath;

//   const SoundDetailScreen({super.key, required this.imagePath});

//   @override
//   State<SoundDetailScreen> createState() => _SoundDetailScreenState();
// }

// class _SoundDetailScreenState extends State<SoundDetailScreen> {
//   static const MethodChannel _channel = MethodChannel('clap_to_find');
//   bool _isPlaying = false;

//   Future<void> playSoundOnly() async {
//     try {
//       await _channel.invokeMethod('playSoundOnly');
//       setState(() {
//         _isPlaying = true;
//       });
//     } on PlatformException catch (e) {
//       print("Failed to play sound: '${e.message}'.");
//     }
//   }

//   Future<void> stopSound() async {
//     try {
//       await _channel.invokeMethod('stopSound');
//       setState(() {
//         _isPlaying = false;
//       });
//     } on PlatformException catch (e) {
//       print("Failed to stop sound: '${e.message}'.");
//     }
//   }

//   void _applyAction() {
//     Navigator.pop(context, widget.imagePath);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sound Detail'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(widget.imagePath),
//             const SizedBox(height: 20),
//             IconButton(
//               icon: Icon(
//                 _isPlaying ? Icons.stop : Icons.play_arrow,
//                 size: 50,
//               ),
//               onPressed: () {
//                 if (_isPlaying) {
//                   stopSound();
//                 } else {
//                   playSoundOnly();
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _applyAction,
//               child: Text('Apply'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
