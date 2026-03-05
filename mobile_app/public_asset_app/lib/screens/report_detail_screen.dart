import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../config.dart';
import '../utils/language_manager.dart';

class ReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final images = widget.report['images'] as List<dynamic>? ?? [];
    // Check for video files in the images list (assuming backend stores them there mixed)
    // or if we decide to store them separately. For now, let's look for known video extensions.
    String? videoUrl;

    for (var item in images) {
      final strParams = item.toString().toLowerCase();
      if (strParams.endsWith('.mp4') ||
          strParams.endsWith('.mov') ||
          strParams.endsWith('.avi')) {
        videoUrl = item.toString();
        if (!videoUrl.startsWith('http')) {
          videoUrl = '${Config.apiBaseUrl}/$videoUrl';
        }
        break; // Only support one video for now
      }
    }

    if (videoUrl != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Error loading video: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        setState(() {
          _isVideoInitialized = true;
        });
      } catch (e) {
        debugPrint('Error initializing video: $e');
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final images = (report['images'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .where((e) {
          final s = e.toLowerCase();
          return !s.endsWith('.mp4') &&
              !s.endsWith('.mov') &&
              !s.endsWith('.avi');
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageManager.instance.t('reports'),
        ), // Used 'reports' as close approximation or add 'report_details'
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildStatusTimeline(
                report['status'] ?? 'pending',
                report['escalationLevel'] ?? 0,
              ),
            ),
            const SizedBox(height: 10),

            // Escalation Badge
            if (report['escalationLevel'] == 2)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  border: Border.all(color: Color(0xFFFFCDD2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFE57373),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ESCALATED TO STATE LEVEL',
                        style: TextStyle(
                          color: Color(0xFFE57373),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (report['escalationLevel'] == 1 &&
                report['isCoolOffPeriod'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  border: Border.all(color: Color(0xFFFFCC80)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFB74D),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning Sent: In 15-Day Cool-Off Period',
                        style: TextStyle(
                          color: Color(0xFFFFB74D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Title
            Text(
              report['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Date & ID
            Text(
              'ID: ${report['id'] ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Description Section
            Text(
              LanguageManager.instance.t('description'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report['description'] ?? 'No description provided.',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // Escalation History Section
            if (report['escalationHistory'] != null &&
                (report['escalationHistory'] as List).isNotEmpty) ...[
              const Text(
                'Timeline & Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (report['escalationHistory'] as List).map((entry) {
                    // entry could be a Map { date: timestamp, note: string }
                    String noteText = entry.toString();
                    if (entry is Map) {
                      noteText = entry['note'] ?? 'Update logged.';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 10,
                            color: Color(0xFF26A69A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              noteText,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Info Grid
            const Text(
              'Information', // Consider adding to translations if needed
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.business,
              LanguageManager.instance.t('department'),
              report['department'] ?? 'General',
            ),
            _buildInfoRow(
              Icons.priority_high,
              LanguageManager.instance.t('priority'),
              report['priority'] ?? 'Normal',
            ),
            _buildInfoRow(
              Icons.location_on,
              LanguageManager.instance.t('location'),
              (report['location'] is Map
                  ? (report['location']['text'] ??
                        report['location_text'] ??
                        'Unknown')
                  : report['location']?.toString() ?? 'Unknown'),
            ),
            if (report['landmark'] != null && report['landmark'].isNotEmpty)
              _buildInfoRow(
                Icons.flag,
                LanguageManager.instance.t('landmark'),
                report['landmark'],
              ),

            const SizedBox(height: 20),

            // Media Section
            if (_isVideoInitialized || images.isNotEmpty) ...[
              const Text(
                'Media', // Consider adding to translations if needed
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],

            // Video Player
            if (_isVideoInitialized)
              Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A202C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Chewie(controller: _chewieController!),
                ),
              ),

            // Image Gallery
            if (images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String imgUrl = images[index];
                  if (!imgUrl.startsWith('http')) {
                    imgUrl = '${Config.apiBaseUrl}/$imgUrl';
                  }
                  return GestureDetector(
                    onTap: () {
                      _showFullScreenImage(context, imgUrl);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, _) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            backgroundColor: Color(0xFF1A202C),
            appBar: AppBar(
              backgroundColor: Color(0xFF1A202C),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: InteractiveViewer(child: Image.network(imageUrl)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline(String status, int escalationLevel) {
    status = status.toLowerCase();

    // Define the full set of possible logical steps based on the report's journey
    List<Map<String, dynamic>> steps = [
      {
        'label': 'Pending',
        'isActive': true,
        'isCompleted': status != 'pending',
      },
    ];

    if (escalationLevel > 0) {
      steps.add({
        'label': 'Escalated',
        'isActive': true,
        'isCompleted': status == 'resolved' || status == 'closed',
      });
    }

    steps.add({
      'label': 'In Progress',
      'isActive': status != 'pending',
      'isCompleted': status == 'resolved' || status == 'closed',
    });
    steps.add({
      'label': 'Resolved',
      'isActive': status == 'resolved' || status == 'closed',
      'isCompleted': status == 'closed',
    });

    // Optional Closed Step
    if (status == 'closed') {
      steps.last['isCompleted'] = true;
      steps.add({'label': 'Closed', 'isActive': true, 'isCompleted': true});
    }

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          final step = steps[stepIndex];
          final isActive = step['isActive'] as bool;
          final isCompleted = step['isCompleted'] as bool;

          Color stepColor = Colors.grey.shade300;
          if (isCompleted) {
            stepColor = const Color(0xFF26A69A); // Teal for completed
          } else if (isActive) {
            stepColor = const Color(0xFFFFB74D); // Orange for active/current
          }

          return Expanded(
            flex: 0,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? stepColor
                        : (isActive ? Colors.white : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stepColor,
                      width: isActive && !isCompleted ? 3 : 0,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : (isActive
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: stepColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : const SizedBox()),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.black87 : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Connector line
          final prevStepCompleted = steps[index ~/ 2]['isCompleted'] as bool;
          return Expanded(
            child: Container(
              height: 2,
              color: prevStepCompleted
                  ? const Color(0xFF26A69A)
                  : Colors.grey.shade300,
              margin: const EdgeInsets.only(
                bottom: 24,
              ), // Offset to align with circles not text
            ),
          );
        }
      }),
    );
  }
}
