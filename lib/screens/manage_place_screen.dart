import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stour/screens/placeStatistic_screen.dart';
import 'addPlace_screen.dart';

class PlaceManagementScreen extends StatelessWidget {
  final String collectionName; // 'stourplace1' hoặc 'food'

  const PlaceManagementScreen({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'DANH SÁCH ĐỊA ĐIỂM',
          style: TextStyle(
            color: Color(0xFF3B6332),
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3B6332)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(collectionName)
                    .where('isAccepted', isEqualTo: true)
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Đã xảy ra lỗi'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final place = docs[index];
                      final name = place['name'] ?? '';
                      final address = place['address'] ?? '';

                      return Card(
                        color: const Color(0xFFFDF0C3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B6332),
                            ),
                          ),
                          subtitle: Text(address),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddPlaceScreen(
                                        placeData: {
                                          'id': place.id,
                                          'name': place['name'],
                                          'address': place['address'],
                                          'rating': place['rating'],
                                          'image': place['image'],
                                          'price': place['price'],
                                          'history': place['history'],
                                          'duration': place['duration'],
                                          'opentime': place['opentime'],
                                          'closetime': place['closetime'],
                                          'district': place['district'],
                                          'city': place['city'],
                                        },
                                        placeId: place.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: Text('Bạn có chắc muốn xóa "$name"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await place.reference.delete();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Xóa thành công')),
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.bar_chart, color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaceStatisticsScreen(
                                        placeId: place.id,
                                        placeName: name,
                                        placeAddress: address,
                                        collectionName: collectionName,
                                      ),
                                    ),
                                  );
                                },
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
