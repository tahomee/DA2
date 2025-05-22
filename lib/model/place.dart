// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stour/util/places.dart';
import 'package:collection/collection.dart';

import '../screens/details.dart';

Stream<List<Place>> getAllPlaceFoodStream(String collection) {
  return FirebaseFirestore.instance
      .collection(collection)
      .snapshots()
      .map((snapshot) {
    List<Place> result = [];

    for (var doc in snapshot.docs) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        Place tmpPlace = Place(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          rating: data['rating']?.toString() ?? '0.0',
          img: data['image'] ?? '',
          price: data['price'] ?? 0,
          history: data['history'] ?? '',
          duration: data['duration'] ?? 0,
          city: data['city'] ?? '',
          closeTime: data['closetime'] ?? 0,
          district: data['district'] ?? '',
          openTime: data['opentime'] ?? 0,
        );

        // Thêm nếu chưa tồn tại trong result (giống logic cũ)
        if (result.firstWhereOrNull((e) => e.id == tmpPlace.id) == null) {
          result.add(tmpPlace);
        }
      }
    }

    return result;
  });
}

void printPlaces() {
  if (places.isEmpty) {
    print('📭 Không có địa điểm nào trong danh sách.');
    return;
  }

  print('📍 Danh sách địa điểm:');
  places.forEach((place) {
    print('🧭 ${place.name} - ${place.address} (${place.city}, ${place.district})');
    print('⭐ Rating: ${place.rating} | 💰 Giá: ${place.price} | 🕒 Giờ mở cửa: ${place.openTime} - ${place.closeTime}');
    print('🖼 Hình ảnh: ${place.img}');
    print('---');
  });
}

Future<void> saveTourToFirebase(String userId, SavedTourClass savedTour) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Phẳng hóa addedPlaces thành List<Map<String, dynamic>> và giữ thông tin ngày
    List<Map<String, dynamic>> formattedPlaces = [];
    for (int dayIndex = 0; dayIndex < savedTour.addedPlaces.length; dayIndex++) {
      var day = savedTour.addedPlaces[dayIndex];
      for (var place in day) {
        formattedPlaces.add({
          'dayIndex': dayIndex + 1,  // Ngày (1, 2, 3,...)
          'id': place.id,
          'name': place.name,
          'address': place.address,
          'rating': place.rating,
          'img': place.img,
          'price': place.price,
          'history': place.history,
          'duration': place.duration,
          'openTime': place.openTime,
          'closeTime': place.closeTime,
          'district': place.district,
          'city': place.city,
        });
      }
    }

    // Lưu tour vào Firestore
    DocumentReference tourRef = await firestore.collection('tours').add({
      'name': savedTour.name,
      'timeSaved': savedTour.timeSaved.toIso8601String(),
      'addedPlaces': formattedPlaces, // Lưu mảng đối tượng đã phẳng hóa với thông tin ngày
    });

    // Cập nhật danh sách tours đã lưu của người dùng
    await firestore.collection('users').doc(userId).update({
      'saveTours': FieldValue.arrayUnion([tourRef.id]),
    });

    print('Tour saved successfully!');
  } catch (e) {
    print('Error saving tour: $e');
  }
}

class SearchByNameWidget extends StatelessWidget {
  final String searchQuery;
  const SearchByNameWidget(this.searchQuery, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stourplace1')
          .orderBy('name')
          .startAt([searchQuery])
          .endAt([searchQuery + '\uf8ff'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var document = snapshot.data!.docs[index];
            var place = Place.fromDocument(document); // 💥 Convert document thành Place

            return ListTile(
              title: Text(place.name),
              leading: Image.network(place.img, width: 50, height: 50, fit: BoxFit.cover),
              subtitle: Text('${place.address} • ${place.city}'), // hoặc lịch sử nếu bạn muốn
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => DetailScreen(
                      placeToDisplay: place, // ✅ truyền đúng Place
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
