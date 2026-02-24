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
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(report['status'] ?? 'pending'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (report['status'] ?? 'PENDING').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ESCALATED TO STATE LEVEL',
                        style: TextStyle(
                          color: Colors.red,
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
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning Sent: In 15-Day Cool-Off Period',
                        style: TextStyle(
                          color: Colors.orange,
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
                            color: Colors.blue,
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
                  color: Colors.black,
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
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
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
}
