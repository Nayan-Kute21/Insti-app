import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/lost_and_found_api.dart';
import '../services/auth_service.dart';

enum ReportType { lost, found }

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  ReportType _reportType = ReportType.lost;

  String _selectedCategory = 'Cycle';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  XFile? _selectedImage;
  String? _selectedLocation;
  final _descriptionController = TextEditingController();

  final _apiService = LostAndFoundApiService();
  List<String> _locations = [];
  bool _isLoadingLocations = true;
  String? _locationsError;
  bool _isSubmitting = false;

  String get dateLabel => _reportType == ReportType.lost ? 'Last Seen on*' : 'Found on*';
  String get locationLabel => _reportType == ReportType.lost ? 'Last Seen at*' : 'Found at*';
  String get postButtonLabel => _reportType == ReportType.lost ? 'Post Lost Item Report' : 'Post Found Item Report';
  String get appBarTitle => _reportType == ReportType.lost ? 'REPORT LOST ITEM' : 'REPORT FOUND ITEM';

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _apiService.fetchLocations();
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationsError = e.toString();
          _isLoadingLocations = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    debugPrint('Picking image...');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25, // Compress image slightly
    );
    if (image != null) {
      final imageSizeInBytes = await image.length();
      final imageSizeInMB = imageSizeInBytes / (1024 * 1024);
      debugPrint('UPLOADING IMAGE SIZE: ${imageSizeInMB.toStringAsFixed(2)} MB');
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'Please fill all required fields, including an image.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = AuthService();
      final String? authToken = await authService.getToken();
      if (authToken == null) throw Exception("User not authenticated.");

      // Step 1: Upload the image and get the URL
      final String imageUrl = await _apiService.uploadImage(
        imageFile: _selectedImage!,
        authToken: authToken,
      );

      final DateTime fullDateTime = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
          _selectedTime!.hour, _selectedTime!.minute);
      final String isoTime = fullDateTime.toIso8601String();

      // Step 2: Create the post using the returned image URL
      await _apiService.createPost(
        landmarkName: _selectedLocation!,
        type: _reportType.name.toUpperCase(),
        extraInfo: '$_selectedCategory: ${_descriptionController.text}',
        mediaUrl: imageUrl,
        // Use the URL from Step 1
        time: isoTime,
        authToken: authToken,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() {
        _isSubmitting = false;
      });
    }
  }
  // The build method and all UI helper widgets remain the same as your provided code.
  // I am including them here for completeness.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Simplified cancel
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E47F7), fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportTypeSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Type of Item*'),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildTextField(
                  label: 'Item Description*',
                  controller: _descriptionController,
                  hint: 'Provide a detailed description of the item',
                  maxLength: 200,
                  maxLines: 4),
              const SizedBox(height: 24),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Item Image*'),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildLocationDropdown(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E47F7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(postButtonLabel, style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // All other UI helper methods below this point are unchanged
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildReportTypeSelector() {
    return SegmentedButton<ReportType>(
      segments: const <ButtonSegment<ReportType>>[
        ButtonSegment<ReportType>(value: ReportType.lost, label: Text('Lost Item'), icon: Icon(Icons.search_off)),
        ButtonSegment<ReportType>(value: ReportType.found, label: Text('Found Item'), icon: Icon(Icons.location_on)),
      ],
      selected: <ReportType>{_reportType},
      onSelectionChanged: (Set<ReportType> newSelection) {
        setState(() {
          _reportType = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: const Color(0xFFF1F3FC),
        foregroundColor: const Color(0xFF1E47F7),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: const Color(0xFF1E47F7),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildCategorySelector() {
    final categories = {
      'Cycle': Icons.directions_bike_outlined, 'Headphones': Icons.headset_mic_outlined, 'Wallet': Icons.wallet_outlined,
      'Bag': Icons.shopping_bag_outlined, 'Electronics': Icons.laptop_chromebook_outlined, 'Document/ID': Icons.description_outlined,
      'Clothing': Icons.checkroom_outlined, 'Other': Icons.category_outlined,
    };
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final icon = categories.values.elementAt(index);
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD1D7F4) : const Color(0xFFF1F3FC),
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: const Color(0xFFA3B0E8)) : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: isSelected ? const Color(0xFF363D52) : const Color(0xFFA3B0E8)),
              const SizedBox(height: 4),
              Text(category, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF363D52) : const Color(0xFFA3B0E8)), overflow: TextOverflow.ellipsis),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, int? maxLength, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            hintStyle: const TextStyle(color: Color(0xFFB4B7C2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF434B66))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF434B66))),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(dateLabel),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF434B66)), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _selectedDate == null ? 'Select Date' : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    style: TextStyle(color: _selectedDate == null ? const Color(0xFFB4B7C2) : const Color(0xFF0D0F14), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Time*'),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF434B66)), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                    style: TextStyle(color: _selectedTime == null ? const Color(0xFFB4B7C2) : const Color(0xFF0D0F14), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(locationLabel),
        if (_isLoadingLocations) const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: CircularProgressIndicator()))
        else if (_locationsError != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Center(child: Text('Error: Could not load locations.', style: const TextStyle(color: Colors.red))))
        else DropdownButtonFormField<String>(
            value: _selectedLocation,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Select a location',
              hintStyle: const TextStyle(color: Color(0xFFB4B7C2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF434B66))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF434B66))),
            ),
            items: _locations.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedLocation = newValue),
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7488DD)),
      ),
      child: _selectedImage == null
          ? Column(children: [
        const Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF7488DD)),
        const SizedBox(height: 8),
        const Text('Upload your image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF363D52))),
        const SizedBox(height: 4),
        const Text('Select 1 Image', style: TextStyle(fontSize: 12, color: Color(0xFF697085))),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library_outlined, size: 18),
          label: const Text('From Gallery'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF363D52)),
        ),
      ])
          : Column(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_selectedImage!.path), height: 150, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Change Image'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF363D52)),
        ),
      ]),
    );
  }
}