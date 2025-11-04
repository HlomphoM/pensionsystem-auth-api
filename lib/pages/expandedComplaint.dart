// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';

class ComplaintDetailsPage extends StatefulWidget {
  const ComplaintDetailsPage({super.key});

  @override
  State<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String complaintId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (complaintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No complaint selected')));
      return;
    }
    await _service.addComplaintMessage(complaintId, text, sender: 'admin');
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final complaintId = args?['id']?.toString() ?? '';

    if (complaintId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No complaint selected or invalid route arguments.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final pensionerNames = args?['pensionerNames']?.toString() ?? 'Unknown';
    final complaintBody = args?['complaintBody']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(pensionerNames)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(12),
            child: Text(complaintBody),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _service.complaintMessages(complaintId),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snap.data!;
                if (messages.isEmpty) return const Center(child: Text('No responses yet'));
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    final isAdmin = (m['sender'] ?? '') == 'admin';
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.blue[300] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(m['message'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Type your response here..'),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(complaintId),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _send(complaintId),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}