import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  List<File> _selectedImages = [];
  bool _isPosting = false;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _submitPost() async {
    if (_postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung bài viết')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Upload ảnh lên Cloudinary
      final imageUrls = await _cloudinaryService.uploadImages(
        _selectedImages.map((file) => file.path).toList(),
      );

      // Lưu bài viết lên Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'content': _postController.text,
        'location': _locationController.text,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.now(),
        'authorId': 'current_user_id', // Thay bằng ID user thực tế
        'likes': 0,
        'comments': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng bài thành công')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng bài: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THÊM BÀI VIẾT', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const CircularProgressIndicator()
                : const Text('Đăng', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      "https://i.pinimg.com/236x/0a/b5/9e/0ab59e7c8e7a1213ff1ee891e98e06ae.jpg?nii=t"),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("HBT", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Bây giờ", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _postController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ cảm nghĩ của bạn...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text('Địa điểm', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Cù Lao Tân Lộc - Vuôn Dừa',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 20),
            const Text('File đính kèm', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Hiển thị danh sách ảnh đã chọn
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 15,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            // Nút thêm ảnh
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40),
                      SizedBox(height: 8),
                      Text('Thêm ảnh'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}