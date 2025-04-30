import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bình luận')),
      body: Center(
        child: Text('Bình luận cho post ID: $postId'),
      ),
    );
  }
}
