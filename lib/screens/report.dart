import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// --- FIX START ---
// 1. Correct the import path and the class name used below.
// The service was defined in 'api_lost_and_found_service.dart' as 'LostAndFoundApiService'.
import '../services/lost_and_found_api.dart';
// --- FIX END ---

// Enum to manage the state of the report type
enum ReportType { lost, found }

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  ReportType _reportType = ReportType.lost; // Default to 'lost'

  String _selectedCategory = 'Cycle';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _markController = TextEditingController();

  // --- FIX START ---
  // 2. Instantiate the correct service class: 'LostAndFoundApiService'.
  final _apiService = LostAndFoundApiService();
  // --- FIX END ---

  List<String> _locations = [];
  String? _selectedLocation;
  bool _isLoadingLocations = true;
  String? _locationsError;

  // Dynamic labels that change based on the report type
  String get itemLabel =>
      _reportType == ReportType.lost ? 'Lost Item Name*' : 'Found Item Name*';
  String get dateLabel =>
      _reportType == ReportType.lost ? 'Last Seen on*' : 'Found on*';
  String get locationLabel =>
      _reportType == ReportType.lost ? 'Last Seen at*' : 'Found at*';
  String get postButtonLabel => _reportType == ReportType.lost
      ? 'Post Lost Item Report'
      : 'Post Found Item Report';
  String get appBarTitle =>
      _reportType == ReportType.lost ? 'REPORT LOST ITEM' : 'REPORT FOUND ITEM';

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _apiService.fetchLocations();
      // Check if the widget is still in the tree before updating the state.
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _markController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // User cannot select a future date
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

  Future<void> _showCancelConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to cancel?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0D0F14),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your progress will be lost',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0D0F14),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF191E2D)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Yes, Cancel',
                    style: TextStyle(
                      color: Color(0xFF191E2D),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E47F7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _showCancelConfirmationDialog,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF1E47F7), fontSize: 16),
            ),
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
                  label: itemLabel,
                  controller: _nameController,
                  hint: 'Enter item name',
                  maxLength: 40),
              const SizedBox(height: 24),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildTextField(
                  label: 'Item Description*',
                  controller: _descriptionController,
                  hint: 'Provide a detailed description',
                  maxLength: 200,
                  maxLines: 4),
              const SizedBox(height: 24),
              _buildSectionTitle('Item Image'),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildTextField(
                  label: 'Unique Identification Mark',
                  controller: _markController,
                  hint: 'e.g., sticker, scratch, serial number',
                  maxLength: 40),
              const SizedBox(height: 24),
              _buildLocationDropdown(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print(
                          'Report posted for a ${_reportType.name} item in $_selectedLocation!');
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E47F7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    postButtonLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return SegmentedButton<ReportType>(
      segments: const <ButtonSegment<ReportType>>[
        ButtonSegment<ReportType>(
          value: ReportType.lost,
          label: Text('Lost Item'),
          icon: Icon(Icons.search_off),
        ),
        ButtonSegment<ReportType>(
          value: ReportType.found,
          label: Text('Found Item'),
          icon: Icon(Icons.location_on),
        ),
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
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = {
      'Cycle': Icons.directions_bike_outlined,
      'Headphones': Icons.headset_mic_outlined,
      'Wallet': Icons.wallet_outlined,
      'Bag': Icons.shopping_bag_outlined,
      'Electronics': Icons.laptop_chromebook_outlined,
      'Document/ID': Icons.description_outlined,
      'Clothing': Icons.checkroom_outlined,
      'Other': Icons.category_outlined,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final icon = categories.values.elementAt(index);
        final isSelected = _selectedCategory == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD1D7F4)
                  : const Color(0xFFF1F3FC),
              borderRadius: BorderRadius.circular(8),
              border:
              isSelected ? Border.all(color: const Color(0xFFA3B0E8)) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: isSelected
                        ? const Color(0xFF363D52)
                        : const Color(0xFFA3B0E8)),
                const SizedBox(height: 4),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF363D52)
                        : const Color(0xFFA3B0E8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      {required String label,
        required TextEditingController controller,
        required String hint,
        int? maxLength,
        int maxLines = 1}) {
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
            counterText: "", // Hides the default counter
            hintStyle: const TextStyle(color: Color(0xFFB4B7C2)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF434B66)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF434B66)),
            ),
          ),
          validator: (value) {
            if (label.endsWith('*') && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(dateLabel),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF434B66)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null
                          ? const Color(0xFFB4B7C2)
                          : const Color(0xFF0D0F14),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF434B66)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : _selectedTime!.format(context),
                    style: TextStyle(
                      color: _selectedTime == null
                          ? const Color(0xFFB4B7C2)
                          : const Color(0xFF0D0F14),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(locationLabel),
        // Show a loading indicator while fetching locations.
        if (_isLoadingLocations)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        // Show an error message if fetching fails.
        else if (_locationsError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Error: Could not load locations.',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        // Show the dropdown once locations are loaded.
        else
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Select a location',
              hintStyle: const TextStyle(color: Color(0xFFB4B7C2)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF434B66)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF434B66)),
              ),
            ),
            items: _locations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
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

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7488DD)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined,
              size: 40, color: Color(0xFF7488DD)),
          const SizedBox(height: 8),
          const Text(
            'Upload your image',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF363D52)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select up to 6 Images',
            style: TextStyle(fontSize: 12, color: Color(0xFF697085)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement choose from gallery
                },
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('From Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF363D52),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}