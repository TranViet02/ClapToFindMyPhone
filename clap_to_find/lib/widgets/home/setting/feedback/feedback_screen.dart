import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _sendFeedback() async {
    final subject = _subjectController.text;
    final message = _messageController.text;

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền tất cả các trường.')),
      );
      return;
    }

    final Email email = Email(
      body: message,
      subject: subject,
      recipients: ['viet04092002@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback đã được gửi.')),
      );
      _subjectController.clear();
      _messageController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gửi Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Nội dung'),
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendFeedback,
              child: Text('Gửi Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
