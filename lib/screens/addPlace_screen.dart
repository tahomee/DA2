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
  final Map<String, dynamic>? placeData;
  final String? placeId;

  const AddPlaceScreen({super.key, this.placeData, this.placeId});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _durationController = TextEditingController();
  final _historyController = TextEditingController();
  final _imgController = TextEditingController();
  String? _rating;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  late GoogleMapController _mapController;
  File? _selectedImage;
  String? _oldImageUrl;

  final List<String> _placeTypes = ['Đặc Sản', 'Văn Hóa'];
  String _selectedType = 'Đặc Sản'; // hoặc 'Văn Hóa' tùy bạn chọn mặc định
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    if (widget.placeData != null) {
      _initializeFormWithData(widget.placeData!);
    } else {
      _getCurrentLocation();
    }
  }

  void _initializeFormWithData(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _selectedType = data['type'] ?? 'Văn Hóa';
    _addressController.text = data['address'] ?? '';
    _cityController.text = data['city'] ?? '';
    _districtController.text = data['district'] ?? '';
    _openTimeController.text = data['opentime']?.toString() ?? '';
    _closeTimeController.text = data['closetime']?.toString() ?? '';
    _historyController.text = data['history'] ?? '';
    _imgController.text = data['img'] ?? '';
    _durationController.text = data['duration']?.toString() ?? '0';
    _priceController.text = data['price']?.toString() ?? '';
    _rating = data['rating']?.toString() ?? '3';
    if (data['image'] != null && (data['image'] as String).isNotEmpty) {
      _oldImageUrl = data['image'];
    }

    if (data['latitude'] != null && data['longitude'] != null) {
      _selectedLocation = LatLng(data['latitude'], data['longitude']);
    }
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Lỗi chọn ảnh: $e');
    }
  }


  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      final uploadedUrls = await _cloudinaryService.uploadImages([image.path]);
      if (uploadedUrls.isNotEmpty) {
        return uploadedUrls.first;
      }
    } catch (e) {
      print('Lỗi tải ảnh lên: $e');
    }
    return null;
  }


  Future<void> _submitPlace() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      } else {
        imageUrl = _oldImageUrl;
      }

      final String newId = uuid.v4(); // id dạng string
      final String collectionName = _selectedType == 'Văn Hóa' ? 'stourplace1' : 'food';

      final placeData = {
        'id': widget.placeId ?? newId,
        'name': _nameController.text,
        'type': _selectedType,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'opentime': int.tryParse(_openTimeController.text),
        'closetime': int.tryParse(_closeTimeController.text),
        'rating': _rating ?? 3.0,
        'price': int.tryParse(_priceController.text) ?? 0,
        'history': _descriptionController.text,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'image': imageUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      final collectionRef = _firestore.collection(collectionName);

      if (widget.placeId != null) {
        // Update
        await collectionRef.doc(widget.placeId).update(placeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật địa điểm thành công!')),
        );
      } else {
        // Add new with custom ID
        placeData['createdAt'] = FieldValue.serverTimestamp();
        await collectionRef.doc(newId).set(placeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm địa điểm thành công!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.placeId != null ? 'CHỈNH SỬA ĐỊA ĐIỂM' : 'THÊM ĐỊA ĐIỂM'),
      ),
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
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPlace,
                child: Text(
                    widget.placeId != null ? 'CẬP NHẬT' : 'THÊM ĐỊA ĐIỂM'),
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
        validator: (value) =>
        (value == null || value.isEmpty)
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
        Expanded(
            child: _buildTextField('Giờ mở cửa (HH:MM)', _openTimeController)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField(
            'Giờ đóng cửa (HH:MM)', _closeTimeController)),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(child: _buildTextField('Giá tiền', _priceController)),
        const SizedBox(width: 10),
        Expanded(
            child: _buildTextField('Thời gian dừng chân', _durationController)),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: _historyController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Mô tả địa điểm',
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
        (value == null || value.isEmpty)
            ? 'Vui lòng nhập mô tả'
            : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ảnh địa điểm'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: _selectedImage != null
              ? Image.file(
              _selectedImage!, width: 150, height: 150, fit: BoxFit.cover)
              : (_oldImageUrl != null && _oldImageUrl!.isNotEmpty)
              ? Image.network(
              _oldImageUrl!, width: 150, height: 150, fit: BoxFit.cover)
              : Container(
            width: 150,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.add_a_photo, size: 40),
          ),
        ),
      ],
    );
  }

}
