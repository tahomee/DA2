import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceStatisticsScreen extends StatelessWidget {
  final String placeId;
  final String placeName;
  final String placeAddress;
  final String collectionName;

  const PlaceStatisticsScreen({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final isFood = collectionName == 'food';
    final placeType = isFood ? 'Đặc sản' : 'Văn hóa';

    final ratingFuture = FirebaseFirestore.instance
        .collection('reviews')
        .where('idLocation', isEqualTo: placeId)
        .get();

    final postsFuture = FirebaseFirestore.instance
        .collection('posts')
        .where('places', arrayContains: placeId)
        .get();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'XEM THỐNG KÊ',
          style: TextStyle(
            color: Color(0xFF3B6332),
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3B6332)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([ratingFuture, postsFuture]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ratingDocs = snapshot.data![0].docs;
          final postDocs = snapshot.data![1].docs;

          // Xử lý rating
          final ratingsCount = List.filled(5, 0); // index 0: 1 sao, index 4: 5 sao
          for (var doc in ratingDocs) {
            final raw = doc['score'];
            final score = int.tryParse(raw.toString());
            if (score != null && score >= 1 && score <= 5) {
              ratingsCount[score - 1]++;
            }
          }

          // Tính tổng thích và bình luận
          final totalLikes = postDocs.fold<int>(
            0,
                (sum, p) => sum + ((p['likes'] ?? 0) as num).toInt(),
          );

          final totalComments = postDocs.fold<int>(
            0,
                (sum, p) => sum + ((p['comments'] ?? 0) as num).toInt(),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tên địa điểm', style: TextStyle(color: Color(0xFF3B6332), fontWeight: FontWeight.w500)),
                      Text(placeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Loại địa điểm', style: TextStyle(color: Color(0xFF3B6332),fontWeight: FontWeight.w500)),
                      Text(placeType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        placeAddress,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),


                const Text(
                  'Thống kê đánh giá',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B6332),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),

                for (int i = 4; i >= 0; i--)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text('${i + 1}'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ratingDocs.isEmpty ? 0 : ratingsCount[i] / ratingDocs.length,
                          minHeight: 6,
                          color: Colors.orange,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${ratingsCount[i]}'),
                    ],
                  ),

                const SizedBox(height: 20),
                const Text(
                  'Thống kê bài viết',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6332),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tổng bài viết: ${postDocs.length}'),
                Text('Tổng yêu thích: $totalLikes'),
                Text('Tổng bình luận: $totalComments'),
              ],
            ),
          );
        },
      ),
    );
  }
}
