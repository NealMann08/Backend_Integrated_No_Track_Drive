/*
 * Help & Support Page
 *
 * Provides users with help resources including FAQ and
 * the ability to contact admin via email for support.
 */

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ipconfig.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
    leading: Icon(Icons.help_outline, color: Colors.black),
    title: 'Help & Support',
    child: SettingsScreen(
      title: 'Help & Support',
      children: <Widget>[
        SettingsGroup(
          title: 'Frequently Asked Questions',
          children: [
            _buildFaqTile(
              'How is my driving score calculated?',
              'Your driving score is calculated based on several factors including speed consistency, smooth acceleration, safe turning, and gradual braking. Each trip contributes to your overall score.',
            ),
            _buildFaqTile(
              'Is my location data tracked?',
              'No! NoTrackDrive processes your driving behavior locally on your device. Your GPS data never leaves your phone, ensuring complete privacy.',
            ),
            _buildFaqTile(
              'How can I improve my score?',
              'Focus on smooth acceleration and braking, maintain consistent speeds, and take turns at safe speeds. Avoid sudden stops and rapid acceleration.',
            ),
            _buildFaqTile(
              'Why is my score not updating?',
              'Scores are updated after each completed trip is analyzed. Make sure you end your trip properly and have a stable internet connection for the data to sync.',
            ),
          ],
        ),
        SizedBox(height: 16),
        SettingsGroup(
          title: 'Contact Support',
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.blue.shade700),
                      SizedBox(width: 12),
                      Text(
                        'Email Support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Have a question, found a bug, or need help? Send us an email and we\'ll get back to you as soon as possible.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _sendSupportEmail(context),
                      icon: Icon(Icons.send),
                      label: Text('Contact Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildFaqTile(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
          ),
        ),
      ],
    );
  }

  Future<void> _sendSupportEmail(BuildContext context) async {
    final String email = AppConfig.adminEmail;
    final String subject = Uri.encodeComponent('NoTrackDrive Support Request');
    final String body = Uri.encodeComponent(
      'Hi NoTrackDrive Support,\n\n'
      'I need help with the following:\n\n'
      '[Please describe your issue or question here]\n\n'
      'Thank you!'
    );

    final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open email app. Please email us at $email'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email. Please contact $email directly.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
