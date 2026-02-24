import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'report_screen.dart';
import 'report_detail_screen.dart';
import 'authorities_list.dart';
import 'admin_reports.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'notification_settings_screen.dart';
import '../config.dart';
import '../utils/language_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userId;
  const HomeScreen({super.key, required this.token, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = false;
  String? errorMessage;
  String? selectedDepartment;
  String selectedStatus = 'all'; // Filter by status
  String sortBy = 'latest'; // Sort option

  // Government departments
  // Government departments - Transformed to getter for translation
  List<Map<String, String>> get departments => [
    {
      'name': LanguageManager.instance.t('departments'),
      'icon': '📋',
      'code': 'all',
    }, // Using 'departments' key for 'All' or create new key 'all'
    {'name': 'PWD', 'icon': '🛣️', 'code': 'pwd'},
    {'name': 'KSEB', 'icon': '⚡', 'code': 'kseb'},
    {'name': 'Water', 'icon': '💧', 'code': 'water'},
    {'name': 'Health', 'icon': '🏥', 'code': 'health'},
    {'name': 'Municipal', 'icon': '🏛️', 'code': 'municipal'},
    {'name': 'Police', 'icon': '👮', 'code': 'police'},
    {'name': 'Education', 'icon': '🎓', 'code': 'education'},
    {'name': 'Sanitation', 'icon': '🧹', 'code': 'sanitation'},
    {'name': 'Transport', 'icon': '🚌', 'code': 'transport'},
    {'name': 'Forest', 'icon': '🌲', 'code': 'forest'},
    {'name': 'Other', 'icon': '📞', 'code': 'other'},
  ];

  List<Map<String, String>> get statuses => [
    {'name': 'All', 'code': 'all'},
    {'name': LanguageManager.instance.t('pending'), 'code': 'pending'},
    {'name': LanguageManager.instance.t('in_progress'), 'code': 'in_progress'},
    {'name': LanguageManager.instance.t('resolved'), 'code': 'resolved'},
    {'name': 'Closed', 'code': 'closed'},
  ];

  @override
  void initState() {
    super.initState();
    fetchRequests();
    searchController.addListener(_filterRequests);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  DateTime _parseDate(dynamic input) {
    if (input == null) return DateTime(2000);
    try {
      if (input is String) return DateTime.parse(input);
      if (input is Map) {
        // Handle Firestore Timestamp like object
        if (input.containsKey('_seconds')) {
          return DateTime.fromMillisecondsSinceEpoch(
            (input['_seconds'] as int) * 1000,
          );
        }
      }
      return DateTime(2000); // Fallback
    } catch (_) {
      return DateTime(2000);
    }
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final baseUrl = Config.apiBaseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/requests?userId=${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(
          data['requests'] ?? data ?? [],
        );

        // Sort by date in descending order (newest first)
        requests.sort((a, b) {
          DateTime dateA = _parseDate(a['createdAt'] ?? a['date']);
          DateTime dateB = _parseDate(b['createdAt'] ?? b['date']);
          return dateB.compareTo(dateA);
        });

        setState(() {
          allRequests = requests;
          filteredRequests = requests;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch requests';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterRequests() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredRequests = allRequests.where((request) {
        final title = (request['title']?.toString() ?? '').toLowerCase();
        final description = (request['description']?.toString() ?? '')
            .toLowerCase();
        final location = (request['location']?.toString() ?? '').toLowerCase();
        final department = (request['department'] ?? request['category'] ?? '')
            .toString()
            .toLowerCase();
        final status = (request['status']?.toString() ?? 'pending')
            .toLowerCase();

        bool matchesSearch =
            query.isEmpty ||
            title.contains(query) ||
            description.contains(query) ||
            location.contains(query) ||
            department.contains(query);

        bool matchesDepartment =
            selectedDepartment == null ||
            selectedDepartment == 'all' ||
            department.contains(selectedDepartment!.toLowerCase());

        bool matchesStatus = false;
        if (selectedStatus == 'all') {
          matchesStatus = true;
        } else if (selectedStatus == 'resolved') {
          matchesStatus = status == 'resolved' || status == 'completed';
        } else {
          matchesStatus = status.contains(selectedStatus);
        }

        return matchesSearch && matchesDepartment && matchesStatus;
      }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (sortBy) {
      case 'oldest':
        filteredRequests.sort((a, b) {
          DateTime dateA = _parseDate(a['createdAt'] ?? a['date']);
          DateTime dateB = _parseDate(b['createdAt'] ?? b['date']);
          return dateA.compareTo(dateB);
        });
        break;
      case 'urgent':
        filteredRequests.sort((a, b) {
          final priorityA = a['priority'] ?? 'normal';
          final priorityB = b['priority'] ?? 'normal';
          const priorityOrder = {'high': 0, 'medium': 1, 'normal': 2, 'low': 3};
          return (priorityOrder[priorityA] ?? 2).compareTo(
            priorityOrder[priorityB] ?? 2,
          );
        });
        break;
      case 'latest':
      default:
        filteredRequests.sort((a, b) {
          DateTime dateA = _parseDate(a['createdAt'] ?? a['date']);
          DateTime dateB = _parseDate(b['createdAt'] ?? b['date']);
          return dateB.compareTo(dateA);
        });
        break;
    }
  }

  String _formatDate(dynamic dateInput) {
    try {
      DateTime date = _parseDate(dateInput);
      if (date.year == 2000) return 'Unknown date';

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Calculate statistics
  Map<String, int> _getStatistics() {
    int total = allRequests.length;
    int pending = allRequests
        .where(
          (r) =>
              (r['status']?.toString() ?? 'pending').toLowerCase() == 'pending',
        )
        .length;
    int resolved = allRequests.where((r) {
      final s = (r['status']?.toString() ?? '').toLowerCase();
      return s == 'resolved' || s == 'completed';
    }).length;
    int inProgress = allRequests
        .where(
          (r) => (r['status']?.toString() ?? '').toLowerCase() == 'in_progress',
        )
        .length;

    return {
      'total': total,
      'pending': pending,
      'resolved': resolved,
      'inProgress': inProgress,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF2563EB)),
                child: Center(
                  child: Text(
                    LanguageManager.instance.t('app_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: Text(LanguageManager.instance.t('departments')),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthoritiesList()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: Text(LanguageManager.instance.t('admin_reports')),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminReports()),
                  );
                },
              ),
              const Divider(),
              ExpansionTile(
                leading: const Icon(Icons.language),
                title: Text(LanguageManager.instance.t('language')),
                children: [
                  ListTile(
                    title: const Text('English'),
                    onTap: () {
                      LanguageManager.instance.changeLanguage('en');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('മലയാളം (Malayalam)'),
                    onTap: () {
                      LanguageManager.instance.changeLanguage('ml');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('हिन्दी (Hindi)'),
                    onTap: () {
                      LanguageManager.instance.changeLanguage('hi');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(LanguageManager.instance.t('logout')),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(LanguageManager.instance.t('logout')),
                      content: Text(
                        LanguageManager.instance.t('logout_confirm'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(LanguageManager.instance.t('cancel')),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx); // Close dialog
                            Navigator.pop(context); // Close drawer
                            await const FlutterSecureStorage().deleteAll();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                          child: Text(LanguageManager.instance.t('confirm')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),
        title: Text(
          LanguageManager.instance.t('app_title'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationSettingsScreen(
                    token: widget.token,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(token: widget.token, userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchRequests,
        color: const Color(0xFF2563EB),
        child: ListView(
          children: [
            // Statistics Dashboard
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageManager.instance.t('dashboard'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatCard(
                          LanguageManager.instance.t('total_reports'),
                          stats['total']!,
                          Colors.blue,
                          Icons.assessment,
                          onTap: () {
                            setState(() {
                              selectedStatus = 'all';
                            });
                            _filterRequests();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          LanguageManager.instance.t('pending'),
                          stats['pending']!,
                          Colors.orange,
                          Icons.schedule,
                          onTap: () {
                            setState(() {
                              selectedStatus = 'pending';
                            });
                            _filterRequests();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          LanguageManager.instance.t('in_progress'),
                          stats['inProgress']!,
                          Colors.purple,
                          Icons.update,
                          onTap: () {
                            setState(() {
                              selectedStatus = 'in_progress';
                            });
                            _filterRequests();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          LanguageManager.instance.t('resolved'),
                          stats['resolved']!,
                          Colors.green,
                          Icons.check_circle,
                          onTap: () {
                            setState(() {
                              selectedStatus = 'resolved';
                            });
                            _filterRequests();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: LanguageManager.instance.t('search_hint'),
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              _filterRequests();
                            },
                            child: Icon(Icons.clear, color: Colors.grey[600]),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Department Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                LanguageManager.instance.t('filter_dept'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final dept = departments[index];
                  final isSelected = selectedDepartment == dept['code'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDepartment = isSelected ? null : dept['code'];
                        });
                        _filterRequests();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dept['icon']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dept['name']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Status and Sort Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageManager.instance.t('status'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            underline: const SizedBox(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? 'all';
                              });
                              _filterRequests();
                            },
                            items: statuses
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status['code'],
                                    child: Text(status['name']!),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageManager.instance.t('sort_by'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            value: sortBy,
                            isExpanded: true,
                            underline: const SizedBox(),
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'latest';
                              });
                              _filterRequests();
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'latest',
                                child: Text('Latest'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest'),
                              ),
                              DropdownMenuItem(
                                value: 'urgent',
                                child: Text('Urgent'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${LanguageManager.instance.t('reports')} (${filteredRequests.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              )
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[600], fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: fetchRequests,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredRequests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        searchController.text.isEmpty
                            ? 'No reports available'
                            : 'No results found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return _buildRequestCard(request);
                  },
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ReportScreen(token: widget.token, userId: widget.userId),
            ),
          );
          if (res == true) {
            // refresh list after successful report
            fetchRequests();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add),
        label: Text(LanguageManager.instance.t('report_problem')),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final title = request['title'] ?? 'Untitled';
    final description = request['description'] ?? '';
    String location = 'Unknown location';
    if (request['location'] is String) {
      location = request['location'];
    } else if (request['location'] is Map) {
      location =
          request['location']['text'] ??
          request['location']['address'] ??
          request['location_text'] ??
          'Unknown location';
    } else if (request['location_text'] != null) {
      location = request['location_text'];
    }
    final category = request['category'] ?? 'General';
    final status = request['status'] ?? 'pending';
    final dateString = request['createdAt'] ?? request['date'] ?? '';
    final priority = request['priority'] ?? 'normal';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(report: request),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: 100, // Fixed width to prevent overflow
                        child: Text(
                          _formatDate(dateString),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (priority.toLowerCase() != 'normal')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildStatCard(
    String title,
    int count,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.deepOrange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
