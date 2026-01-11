import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ISPRegistrationPage extends StatelessWidget {
  const ISPRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text('Insurance Provider Registration'),
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976D2).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          size: 64,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Title
                      Text(
                        'Insurance Service Provider Registration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),

                      // Description
                      Text(
                        'Thank you for your interest in DriveGuard! To register as an Insurance Service Provider, please follow the steps below.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // Steps container
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to Register:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildStep(
                              '1',
                              'Send an email to admin@gmail.com',
                              'Use your official company email address',
                            ),
                            SizedBox(height: 12),
                            _buildStep(
                              '2',
                              'Include your company details',
                              'Company name, state of operation, and insurance license number',
                            ),
                            SizedBox(height: 12),
                            _buildStep(
                              '3',
                              'Provide proof of authenticity',
                              'Attach a copy of your insurance license or registration certificate',
                            ),
                            SizedBox(height: 12),
                            _buildStep(
                              '4',
                              'Wait for verification',
                              'Our team will review your request within 2-3 business days',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Required information box
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                                SizedBox(width: 8),
                                Text(
                                  'Required Information:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildBullet('Company legal name'),
                            _buildBullet('State(s) of operation'),
                            _buildBullet('Insurance license number'),
                            _buildBullet('Primary contact name and phone'),
                            _buildBullet('Company email domain'),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Email button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: 'admin@gmail.com',
                              query: 'subject=Insurance Service Provider Registration Request&body=Company Name: \nState of Operation: \nInsurance License Number: \nContact Name: \nContact Phone: \n\nPlease attach proof of insurance license.',
                            );

                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please email admin@gmail.com with your registration request'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.email),
                          label: Text(
                            'Email admin@gmail.com',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Back button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1976D2),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Color(0xFF1976D2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Color(0xFF1976D2))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
