import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/cloudinary_service.dart';

import 'widgets/image_painter_widget.dart';

class CreateReportView extends StatefulWidget {
  const CreateReportView({super.key});

  @override
  State<CreateReportView> createState() => _CreateReportViewState();
}

class _CreateReportViewState extends State<CreateReportView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController(); // NEW
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  Position? _position;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (pickedFile == null) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImage = pickedFile;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _fetchLocation() async {
    if (_isLoadingLocation) {
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui long bat dinh vi de gui bao cao.'),
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Khong duoc cap quyen vi tri.')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _position = pos;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khong lay duoc vi tri hien tai.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ban can dang nhap de gui bao cao.')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui long chon anh su co.')));
      return;
    }

    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long lay vi tri truoc khi gui.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageUrl = await CloudinaryService.uploadImage(
        _selectedImage!.path,
      );

      final incident = Incident(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: imageUrl,
        lat: _position!.latitude,
        lng: _position!.longitude,
        status: IncidentStatus.pending,
        
        uid: uid,
        createdAt: DateTime.now(),
      );

     if (!mounted) return;
      await context.read<IncidentProvider>().addIncident(incident);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gui bao cao thanh cong.')));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gui bao cao that bai. Thu lai sau.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationText = _position == null
        ? 'Chua co du lieu vi tri'
        : 'Lat: ${_position!.latitude.toStringAsFixed(6)} - Lng: ${_position!.longitude.toStringAsFixed(6)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Gui bao cao su co')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tieu de',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui long nhap tieu de.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Mo ta',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui long nhap mo ta su co.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Dia chi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui long nhap dia chi su co.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ImagePainterWidget(
                imageBytes: _selectedImageBytes,
                onPickFromCamera: () => _pickImage(ImageSource.camera),
                onPickFromGallery: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location),
                      const SizedBox(width: 12),
                      Expanded(child: Text(locationText)),
                      IconButton(
                        onPressed: _isLoadingLocation ? null : _fetchLocation,
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Dang gui...' : 'Xac nhan gui'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
