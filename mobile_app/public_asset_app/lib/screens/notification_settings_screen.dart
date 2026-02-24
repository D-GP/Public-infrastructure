import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String token;
  final String userId;

  const NotificationSettingsScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool isLoading = true;
  bool isSaving = false;

  // Default settings
  Map<String, bool> settings = {'email': true, 'push': true, 'whatsapp': true};

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/users/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        if (user['notification_settings'] != null) {
          final ns = user['notification_settings'];
          setState(() {
            settings['email'] = ns['email'] ?? true;
            settings['push'] = ns['push'] ?? true;
            settings['whatsapp'] = ns['whatsapp'] ?? true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateSettings(String key, bool value) async {
    setState(() {
      settings[key] = value;
      isSaving = true;
    });

    try {
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/api/users/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'notification_settings': settings}),
      );

      if (response.statusCode != 200) {
        // Revert on failure
        setState(() => settings[key] = !value);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update settings')),
          );
        }
      }
    } catch (e) {
      // Revert on failure
      setState(() => settings[key] = !value);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage your notification preferences',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Email Notifications',
                          'Receive updates via email',
                          Icons.email,
                          'email',
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          'Push Notifications',
                          'Receive updates on your device',
                          Icons.notifications_active,
                          'push',
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          'WhatsApp Notifications',
                          'Receive urgent updates via WhatsApp',
                          Icons.chat,
                          'whatsapp',
                        ),
                      ],
                    ),
                  ),
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    String key,
  ) {
    return SwitchListTile(
      value: settings[key] ?? true,
      onChanged: (val) => updateSettings(key, val),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2563EB)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      activeThumbColor: const Color(0xFF2563EB),
    );
  }
}
