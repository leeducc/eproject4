import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/services/profile_api.dart';
import '../../../data/services/media_api.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;

  const EditProfileScreen({Key? key, this.initialProfile}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  DateTime? _selectedBirthday;
  String? _avatarUrl;
  File? _localImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile ?? {};
    _nameController = TextEditingController(text: profile['fullName'] ?? '');
    _bioController = TextEditingController(text: profile['bio'] ?? '');
    _addressController = TextEditingController(text: profile['address'] ?? '');
    _phoneController = TextEditingController(text: profile['phoneNumber'] ?? '');
    _avatarUrl = profile['avatarUrl'];
    if (profile['birthday'] != null) {
      _selectedBirthday = DateTime.parse(profile['birthday']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle, 
            aspectRatioPresets: [CropAspectRatioPreset.square], 
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            cropStyle: CropStyle.circle, 
            aspectRatioPresets: [CropAspectRatioPreset.square], 
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _localImage = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? finalAvatarUrl = _avatarUrl;

      if (_localImage != null) {
        final uploadedUrl = await MediaApi.uploadAvatar(_localImage!);
        if (uploadedUrl != null) {
          finalAvatarUrl = uploadedUrl;
        }
      }

      final profileData = {
        'fullName': _nameController.text,
        'avatarUrl': finalAvatarUrl,
        'bio': _bioController.text,
        'address': _addressController.text,
        'birthday': _selectedBirthday?.toIso8601String().split('T')[0],
        'phoneNumber': _phoneController.text,
      };

      final success = await ProfileApi.updateProfile(profileData);

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('Save profile error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://i.imgur.com/BoN9kdC.png';
    if (url.startsWith('http')) return url;
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'http://10.0.2.2:8123';
    return '$baseUrl$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!)
                              : NetworkImage(_getAvatarUrl(_avatarUrl)) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectBirthday(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Birthday',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedBirthday == null
                              ? 'Select Birthday'
                              : '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}