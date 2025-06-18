import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stour/util/const.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  Future<void> _addComment() async {
    final TextEditingController _controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm bình luận"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Nhập bình luận của bạn"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: const Text("Gửi")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && userData != null) {
      try {
        final newCommentRef = await _firestore.collection('comments').add({
          'post': widget.postId,
          'value': result,
          'userId': currentUser!.uid,
          'username': userData!['username'] ?? 'Ẩn danh',
          'avatar': userData!['avatar'] ?? '',
          'time': Timestamp.now(),
          'reply': [],
        });

        await _firestore.collection('posts').doc(widget.postId).update({
          'ccomments': FieldValue.arrayUnion([newCommentRef.id]),
          'comments': FieldValue.increment(1),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsQuery = _firestore
        .collection('comments')
        .where('post', isEqualTo: widget.postId)
        .orderBy('time', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BÌNH LUẬN',
          style: TextStyle(color: Color.fromARGB(255, 35, 52, 10)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 35, 52, 10)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Constants.lightgreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: commentsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có bình luận nào."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: data['avatar'] != null && data['avatar'] != ''
                      ? NetworkImage(data['avatar'])
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                title: Text(data['username'] ?? 'Ẩn danh'),
                subtitle: Text(data['value'] ?? 'Không có nội dung'),
                trailing: Text(
                  (data['time'] as Timestamp).toDate().toString().substring(0, 16),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addComment,
        backgroundColor: Constants.lightgreen,
        tooltip: "Thêm bình luận",
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
