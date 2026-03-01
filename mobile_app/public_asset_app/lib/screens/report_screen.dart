import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'dart:convert';
import '../utils/language_manager.dart';
import '../utils/pathanamthitta_data.dart';

class ReportScreen extends StatefulWidget {
  final String token;
  final String userId;
  const ReportScreen({super.key, required this.token, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final reporterNameCtrl = TextEditingController();
  final reporterEmailCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();

  String department = 'PWD';
  String priority = 'normal';
  String district = PathanamthittaData.district;
  String? selectedLocalBodyType;
  String? selectedLocalBodyName;
  String? selectedDepartmentOffice;
  String locationText = '';
  final locationCtrl =
      TextEditingController(); // This will act as the "Place / Locality" text field in addition to GPS
  List<XFile> images = [];
  bool isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    reporterNameCtrl.dispose();
    reporterEmailCtrl.dispose();
    landmarkCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 75);
      if (picked.isNotEmpty) {
        setState(() {
          images.addAll(picked);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          images.add(picked); // Add video to the same list for simplicity
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video pick failed: $e')));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied'),
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        locationText = '${pos.latitude},${pos.longitude}';
        locationCtrl.text = locationText;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  Future<void> sendOtpAndShowDialog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedLocalBodyType == null || selectedLocalBodyName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your local body type and name.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (selectedDepartmentOffice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select the specific department office.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('${Config.apiBaseUrl}/api/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': reporterEmailCtrl.text.trim()}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showOtpDialog();
      } else {
        final resBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resBody['msg'] ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enter OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('We have sent a 6-digit OTP to your email.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (otpController.text.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid 6-digit OTP'),
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isVerifying = true);
                          bool success = await _submit(
                            otpController.text.trim(),
                          );
                          if (context.mounted) {
                            setDialogState(() => isVerifying = false);
                            if (success) {
                              Navigator.pop(context); // Close dialog
                            }
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify & Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _submit(String otp) async {
    setState(() => isSubmitting = true);

    try {
      final uri = Uri.parse('${Config.apiBaseUrl}/api/requests');
      final req = http.MultipartRequest('POST', uri);

      req.fields['title'] = titleCtrl.text.trim();
      req.fields['description'] = descCtrl.text.trim();
      req.fields['district'] = district;
      req.fields['local_body_type'] = selectedLocalBodyType!;
      req.fields['local_body_name'] = selectedLocalBodyName!;
      req.fields['place'] = locationCtrl.text.trim();
      req.fields['location'] = locationText.isNotEmpty ? locationText : '';
      req.fields['department'] = department;
      req.fields['department_office'] = selectedDepartmentOffice ?? '';
      req.fields['priority'] = priority;
      req.fields['reporter_name'] = reporterNameCtrl.text.trim();
      req.fields['reporter_email'] = reporterEmailCtrl.text.trim();
      req.fields['landmark'] = landmarkCtrl.text.trim();
      req.fields['userId'] = widget.userId;
      req.fields['otp'] = otp;

      for (var file in images) {
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename: file.name,
        );
        req.files.add(multipartFile);
      }

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final resp = await http.Response.fromStream(streamed);

      if (!mounted) {
        return false;
      }
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageManager.instance.t('submission_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${resp.body}'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection Error: ${e.toString()}. Check your internet or server URL.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.instance.t('report_problem')),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: LanguageManager.instance.t('title'),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? LanguageManager.instance.t('required')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: LanguageManager.instance.t('description'),
                ),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty
                    ? LanguageManager.instance.t('required')
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: reporterNameCtrl,
                      decoration: InputDecoration(
                        labelText: LanguageManager.instance.t('your_name'),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? LanguageManager.instance.t('required')
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: reporterEmailCtrl,
                      decoration: InputDecoration(
                        labelText: LanguageManager.instance.t('your_email'),
                      ),
                      validator: (v) => v == null || !v.contains('@')
                          ? LanguageManager.instance.t('invalid_email')
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: landmarkCtrl,
                decoration: InputDecoration(
                  labelText: LanguageManager.instance.t('landmark'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    // Local Body Type dropdown
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLocalBodyType,
                      items: PathanamthittaData.localBodyTypes.map((
                        String val,
                      ) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedLocalBodyType = v;
                          selectedLocalBodyName = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Local Body Type',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // Local Body Name dropdown
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLocalBodyName,
                      items:
                          (selectedLocalBodyType == null
                                  ? <String>[]
                                  : PathanamthittaData.getLocalBodies(
                                      selectedLocalBodyType!,
                                    ))
                              .map((String val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              })
                              .toList(),
                      onChanged: selectedLocalBodyType == null
                          ? null
                          : (v) => setState(() => selectedLocalBodyName = v),
                      decoration: const InputDecoration(
                        labelText: 'Local Body Name',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: department,
                      items: PathanamthittaData.departments.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          department = v ?? 'PWD';
                          selectedDepartmentOffice = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: LanguageManager.instance.t('department'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: priority,
                      items: const [
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                      ],
                      onChanged: (v) =>
                          setState(() => priority = v ?? 'normal'),
                      decoration: InputDecoration(
                        labelText: LanguageManager.instance.t('priority'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Department Subdivision dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedDepartmentOffice,
                items:
                    PathanamthittaData.departmentSubdivisions[department]?.map((
                      String val,
                    ) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList() ??
                    [],
                onChanged: (v) => setState(() => selectedDepartmentOffice = v),
                decoration: const InputDecoration(
                  labelText: 'Department Subdivision / Office',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a department office';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: 'Place / Locality',
                        hintText: "Enter place or use GPS ->",
                      ),
                      controller: locationCtrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(LanguageManager.instance.t('use_current')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Images
              Text(
                LanguageManager.instance.t('photos'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo,
                                size: 30,
                                color: Colors.black45,
                              ),
                              Text(
                                LanguageManager.instance.t('photos'),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.video_call,
                                size: 30,
                                color: Colors.black45,
                              ),
                              Text(
                                LanguageManager.instance.t('video'),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ...images.map((x) {
                      bool isVideo =
                          x.path.toLowerCase().endsWith('.mp4') ||
                          x.path.toLowerCase().endsWith('.mov');
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Container(
                                      color: Colors.black,
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Image.file(File(x.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => images.remove(x)),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.close, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : sendOtpAndShowDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(LanguageManager.instance.t('submit_report')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
