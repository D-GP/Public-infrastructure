import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  bool isLoading = true;
  List<dynamic> reports = [];
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final baseUrl = Config.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/api/requests');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          reports = data['requests'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(String id, String status) async {
    try {
      final baseUrl = Config.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/api/requests/$id');
      final resp = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      if (resp.statusCode == 200) fetchReports();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: RefreshIndicator(
        onRefresh: fetchReports,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: reports.length,
                itemBuilder: (context, i) {
                  final r = reports[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(r['title'] ?? 'No title'),
                      subtitle: Text(r['description'] ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) =>
                            _changeStatus(r['id'] ?? r['docId'] ?? '', v),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'in_progress',
                            child: Text('Mark In Progress'),
                          ),
                          const PopupMenuItem(
                            value: 'resolved',
                            child: Text('Mark Resolved'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
