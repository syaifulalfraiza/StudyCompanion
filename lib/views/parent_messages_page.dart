import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParentMessagesPage extends StatefulWidget {
  const ParentMessagesPage({super.key});

  @override
  State<ParentMessagesPage> createState() => _ParentMessagesPageState();
}

class _ParentMessagesPageState extends State<ParentMessagesPage> {
  static const primary = Color(0xFF800020);
  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    final now = DateTime.now();
    _messages = [
      MessageModel(
        id: 'msg1',
        sender: 'Cikgu Ahmad bin Hassan',
        subject: 'Mathematics Assignment Update',
        body: 'Dear parent, your child has shown excellent progress in mathematics this week. Keep up the good work!',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      MessageModel(
        id: 'msg2',
        sender: 'Puan Siti Nurhaliza',
        subject: 'Parent-Teacher Meeting Invitation',
        body: 'You are cordially invited to attend the quarterly parent-teacher meeting on February 20, 2026 at 2:00 PM. We look forward to discussing your child\'s academic performance and development.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg3',
        sender: 'School Administrator',
        subject: 'Upcoming School Event',
        body: 'We are pleased to announce the Annual Sports Day on March 5, 2026. All parents are welcome to attend and support our students!',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg4',
        sender: 'Cikgu Ravi Kumar',
        subject: 'Science Project Reminder',
        body: 'This is a friendly reminder that the science project is due next Friday. Please ensure your child completes the required research and presentation materials.',
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _deleteAllMessages,
            tooltip: 'Delete All',
          ),
        ],
      ),
      body: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageCard(message);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showComposeDialog,
        backgroundColor: primary,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Compose', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your inbox is empty',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(MessageModel message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: message.isRead ? 0 : 2,
      color: message.isRead ? Colors.white : const Color(0xFFFFF9F0),
      child: InkWell(
        onTap: () => _viewMessage(message),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(
                  message.isRead ? Icons.mail_outline : Icons.mail,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.subject,
                      style: TextStyle(
                        fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteMessage(message);
                  } else if (value == 'toggle_read') {
                    _toggleReadStatus(message);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle_read',
                    child: Row(
                      children: [
                        Icon(
                          message.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(message.isRead ? 'Mark as Unread' : 'Mark as Read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _viewMessage(MessageModel message) {
    setState(() {
      message.isRead = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.subject,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'From: ${message.sender}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              DateFormat('MMM d, yyyy - h:mm a').format(message.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showReplyDialog(message);
            },
            icon: const Icon(Icons.reply),
            label: const Text('Reply'),
            style: ElevatedButton.styleFrom(backgroundColor: primary),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(MessageModel originalMessage) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to: ${originalMessage.sender}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Re: ${originalMessage.subject}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your reply here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply sent successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showComposeDialog() {
    final recipientController = TextEditingController();
    final subjectController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compose Message'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  labelText: 'To',
                  hintText: 'Teacher or school staff',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (recipientController.text.trim().isNotEmpty &&
                  subjectController.text.trim().isNotEmpty &&
                  bodyController.text.trim().isNotEmpty) {
                setState(() {
                  _messages.insert(
                    0,
                    MessageModel(
                      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                      sender: 'You (Reply to ${recipientController.text})',
                      subject: subjectController.text,
                      body: bodyController.text,
                      timestamp: DateTime.now(),
                      isRead: true,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.remove(message);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAllMessages() {
    if (_messages.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Messages'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All messages deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _toggleReadStatus(MessageModel message) {
    setState(() {
      message.isRead = !message.isRead;
    });
  }
}

class MessageModel {
  final String id;
  final String sender;
  final String subject;
  final String body;
  final DateTime timestamp;
  bool isRead;

  MessageModel({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}
