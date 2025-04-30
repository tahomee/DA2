import 'dart:io';
import 'dart:convert'; // Nếu cần dùng jsonDecode trong CloudinaryService
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';
import 'package:stour/assets/icons/send_svg.dart' as sendIcon;
import 'package:flutter_svg/flutter_svg.dart';
import '../util/places.dart';

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
  Map<String, dynamic>? userData;
  final User? user = FirebaseAuth.instance.currentUser; // Thêm dòng này để lấy user hiện tại

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _locationController.text = currentLocationDetail[1]; // Set giá trị địa điểm luôn khi mở screen
  }
  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }
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

      // Tạo bài post mới
      final postRef = await FirebaseFirestore.instance.collection('posts').add({
        'content': _postController.text,
        'location': _locationController.text,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.now(),
        'authorId': user?.uid,
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'shares':0,
      });

      // Cập nhật field "posts" trong document user
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'posts': FieldValue.arrayUnion([postRef.id])  // thêm id bài post vào mảng posts
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng bài thành công')),
      );
      Navigator.of(context).pop(true); // Trả về 'true' khi đăng thành công
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
        title: const Text(
          'THÊM BÀI VIẾT',
          style: TextStyle(
            color: Color(0xFF3B6332),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const CircularProgressIndicator()
                : SvgPicture.string(sendIcon.sendSVG, height: 40, width: 40),
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
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userData?['avatar'] != null
                      ? NetworkImage(userData?['avatar'])
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?['username'] ?? "Người dùng",
                      style: const TextStyle(
                        color: Color(0xFF3B6332),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            const Text('Địa điểm', style: TextStyle(color: Color(0xFF3B6332), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFFD166)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('File đính kèm', style: TextStyle(color: Color(0xFF3B6332), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                          right: 5,
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
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 30, color: Color(0xFFFFD166)),
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
