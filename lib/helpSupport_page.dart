import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showContactAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.blue.shade700),
            SizedBox(width: 12),
            Text('Contact Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a message to our support team about bugs, issues, or any feedback you have.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your issue or feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _messageController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a message')),
                );
                return;
              }

              String message = _messageController.text.trim();
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'admin@gmail.com',
                query: 'subject=DriveGuard Support Request&body=${Uri.encodeComponent(message)}',
              );

              Navigator.pop(context);
              _messageController.clear();

              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Message prepared. Email admin@gmail.com with your feedback.'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please email admin@gmail.com with your feedback.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
    leading: Icon(Icons.help_outline, color: Colors.black),
    title: 'Help & Support',
    child: SettingsScreen(
      title: 'Help & Support',
      children: <Widget>[
        SettingsGroup(
          title: 'Contact Us',
          children: [
            SimpleSettingsTile(
              title: 'Report a Bug or Send Feedback',
              subtitle: 'Send a message to our support team',
              leading: Icon(Icons.bug_report, color: Colors.orange),
              onTap: _showContactAdminDialog,
            ),
          ],
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For immediate assistance, you can also email us directly at admin@gmail.com',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
