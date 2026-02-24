import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final String userId;

  const ProfileScreen({super.key, required this.token, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;
  Map<String, dynamic>? userData;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController ageController;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    ageController = TextEditingController();
    fetchProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);
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
        setState(() {
          userData = data['user'];
          _populateControllers();
          isLoading = false;
        });
      } else {
        _showError('Failed to load profile');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _populateControllers() {
    if (userData != null) {
      nameController.text = userData!['name'] ?? '';
      phoneController.text = userData!['phone'] ?? '';
      addressController.text = userData!['address'] ?? '';
      ageController.text = (userData!['age'] ?? '').toString();
      selectedGender = userData!['gender'];
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    try {
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/api/users/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'age': int.tryParse(ageController.text),
          'gender': selectedGender,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Profile updated successfully');
        setState(() {
          isEditing = false;
          // Update local data
          userData!['name'] = nameController.text;
          userData!['phone'] = phoneController.text;
          userData!['address'] = addressController.text;
          userData!['age'] = int.tryParse(ageController.text);
          userData!['gender'] = selectedGender;
        });
      } else {
        _showError('Failed to update profile');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  // Cancel editing, reset fields
                  _populateControllers();
                }
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            (userData?['name'] ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData?['email'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Form
                  Form(
                    key: _formKey,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              label: 'Full Name',
                              controller: nameController,
                              icon: Icons.person,
                              enabled: isEditing,
                              validator: (v) =>
                                  v!.isEmpty ? 'Name is required' : null,
                            ),
                            const Divider(height: 24),
                            _buildTextField(
                              label: 'Phone Number',
                              controller: phoneController,
                              icon: Icons.phone,
                              enabled: isEditing,
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  v!.length < 10 ? 'Invalid phone' : null,
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Age',
                                    controller: ageController,
                                    icon: Icons.calendar_today,
                                    enabled: isEditing,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: isEditing
                                      ? DropdownButtonFormField<String>(
                                          initialValue: selectedGender,
                                          decoration: InputDecoration(
                                            labelText: 'Gender',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                          items: ['Male', 'Female', 'Other']
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                            () => selectedGender = v,
                                          ),
                                        )
                                      : _buildTextField(
                                          label: 'Gender',
                                          controller: TextEditingController(
                                            text: selectedGender,
                                          ),
                                          icon: Icons.people,
                                          enabled: false,
                                        ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildTextField(
                              label: 'Address',
                              controller: addressController,
                              icon: Icons.home,
                              enabled: isEditing,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isEditing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey[700],
            fontWeight: enabled ? FontWeight.w500 : FontWeight.normal,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: enabled
                  ? const BorderSide(color: Colors.grey)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
