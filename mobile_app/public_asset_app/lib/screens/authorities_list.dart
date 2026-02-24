import 'package:flutter/material.dart';
import 'authority_reports.dart';

class AuthoritiesList extends StatelessWidget {
  const AuthoritiesList({super.key});

  static const List<Map<String, String>> departments = [
    {'code': 'PWD', 'name': 'Public Works Department'},
    {'code': 'KSEB', 'name': 'Electricity (KSEB)'},
    {'code': 'Water', 'name': 'Water Department'},
    {'code': 'Health', 'name': 'Health Department'},
    {'code': 'Municipal', 'name': 'Municipal Corporation'},
    {'code': 'Police', 'name': 'Police'},
    {'code': 'Education', 'name': 'Education'},
    {'code': 'Other', 'name': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments'), backgroundColor: const Color(0xFF2563EB)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = departments[i];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(d['name']!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuthorityReports(department: d['code']!))),
          );
        },
      ),
    );
  }
}
