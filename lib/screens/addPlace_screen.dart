import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import '../services/cloudinary_service.dart';

const uuid = Uuid();

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  String _selectedType = 'Du lịch';
  List<File> _selectedImages = [];
  double? _rating;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  late GoogleMapController _mapController;

  final List<String> _placeTypes = ['Du lịch', 'Ăn uống', 'Giải trí'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy vị trí: $e')),
      );
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _addressController.text =
        '${place.street}, ${place.subLocality}, ${place.locality}';
        _cityController.text = place.administrativeArea ?? '';
        _districtController.text = place.subAdministrativeArea ?? '';
      }
    } catch (e) {
      print('Lỗi địa chỉ: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (_selectedImages.length + pickedFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chỉ được chọn tối đa 5 ảnh')),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      print('Lỗi chọn ảnh: $e');
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      try {
        // Assuming `image.path` is passed to the upload method
        final uploadedUrls = await _cloudinaryService.uploadImages(
          [image.path], // Passing image path here
        );
        imageUrls.addAll(uploadedUrls); // Add the returned URLs to the list
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
  }

  Future<void> _submitPlace() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn ít nhất một ảnh')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> imageUrls = await _uploadImagesToCloudinary(_selectedImages);

      final newPlace = {
        'name': _nameController.text,
        'type': _selectedType,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'openTime': double.tryParse(_openTimeController.text) ?? 0.0,
        'closeTime': double.tryParse(_closeTimeController.text) ?? 0.0,
        'rating': _rating ?? 3.0,
        'minPrice': int.tryParse(_minPriceController.text) ?? 0,
        'maxPrice': int.tryParse(_maxPriceController.text) ?? 0,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'image': imageUrls.first,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };


      await _firestore.collection('stourplace1').add(newPlace);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm địa điểm thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm địa điểm: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THÊM ĐỊA ĐIỂM')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Tên địa điểm', _nameController),
              _buildDropdown(),
              const SizedBox(height: 10),
              _buildMapPicker(),
              _buildTextField('Địa chỉ', _addressController),
              _buildTextField('Thành phố', _cityController),
              _buildTextField('Quận/Huyện', _districtController),
              _buildTimeFields(),
              _buildPriceFields(),
              _buildDescriptionField(),
              _buildImagePicker(),
              ElevatedButton(
                onPressed: _submitPlace,
                child: const Text('THÊM ĐỊA ĐIỂM'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? 'Vui lòng nhập $label'
            : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: _placeTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildMapPicker() {
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation ?? const LatLng(10.870051, 106.803011),
          zoom: 14,
        ),
        myLocationEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
        onTap: (position) {
          setState(() => _selectedLocation = position);
          _getAddressFromLatLng(Position(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          ));
        },
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: const MarkerId('picked_location'),
            position: _selectedLocation!,
          )
        }
            : {},
      ),
    );
  }

  Widget _buildTimeFields() {
    return Row(
      children: [
        Expanded(child: _buildTextField('Giờ mở cửa (HH:MM)', _openTimeController)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('Giờ đóng cửa (HH:MM)', _closeTimeController)),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(child: _buildTextField('Giá thấp nhất', _minPriceController)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('Giá cao nhất', _maxPriceController)),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Mô tả địa điểm',
        border: OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Vui lòng nhập mô tả'
          : null,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ảnh địa điểm (tối đa 5 ảnh):'),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Image.file(_selectedImages[index], width: 100, fit: BoxFit.cover),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () =>
                          setState(() => _selectedImages.removeAt(index)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ElevatedButton(
          onPressed: _pickImages,
          child: const Text('Chọn ảnh'),
        ),
      ],
    );
  }
}
