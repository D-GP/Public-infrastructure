import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AuthorityReports extends StatefulWidget {
  final String department;
  const AuthorityReports({super.key, required this.department});

  @override
  State<AuthorityReports> createState() => _AuthorityReportsState();
}

class _AuthorityReportsState extends State<AuthorityReports> {
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
      final uri = Uri.parse(
        '$baseUrl/api/requests?department=${Uri.encodeComponent(widget.department)}',
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} Reports'),
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
                      trailing: Text(
                        (r['status'] ?? 'pending').toString().toUpperCase(),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
