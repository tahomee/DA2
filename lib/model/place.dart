// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stour/util/places.dart';
import 'package:collection/collection.dart';

Future<List<Place>> getAllPlaceFood(String collection) async {
  try {
    CollectionReference place = FirebaseFirestore.instance.collection(collection);
    QuerySnapshot snapshot = await place.get();

    for (var documentSnapshot in snapshot.docs) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

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

        if (collection == 'stourplace1') {
          if (places.firstWhereOrNull((element) => element.id == tmpPlace.id) == null) {
            places.add(tmpPlace);
          }
        } else {
          if (food.firstWhereOrNull((element) => element.id == tmpPlace.id) == null) {
            food.add(tmpPlace);
          }
        }
      }
    }
  } catch (e) {
    print("❌ Error fetching data from Firestore ($collection): $e");
  }

  return collection == 'stourplace1' ? places : food;
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

// void getAllPlaceFood(String collection) {
//   CollectionReference place = FirebaseFirestore.instance.collection(collection);
//   place.get().then((QuerySnapshot snapshot) {
//
//     snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
//       if (documentSnapshot.exists) {
//         Map<String, dynamic> data =
//             documentSnapshot.data() as Map<String, dynamic>;
//         print("⏰ openTime kiểu: ${data['opentime']} (${data['opentime'].runtimeType})");
//         print(" dữ liệu: ${data} ");
//
//         Place tmpPlace = Place(
//           id: data['id'],
//           name: data['name'],
//           address: data['address'],
//           rating: data['rating'],
//           img: data['image'],
//           price: data['price'],
//           history: data['history'],
//           duration: data['duration'],
//           city: data['city'],
//           closeTime: data['closetime'],
//           district: data['district'],
//           openTime: data['opentime'],
//         );
//         if (collection == 'stourplace1') {
//           if (places.firstWhereOrNull((element) => element.id == tmpPlace.id) ==
//               null) {
//             places.add(tmpPlace);
//           }
//         } else {
//           if (food.firstWhereOrNull((element) => element.id == tmpPlace.id) ==
//               null) {
//             food.add(tmpPlace);
//           }
//         }
//       }
//     });
//   });
//
//  }

class SearchByNameWidget extends StatelessWidget {
  final String searchQuery;
  const SearchByNameWidget(this.searchQuery, {super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stourplace1')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: '${searchQuery}z')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        FirebaseFirestore.instance
            .collection('stourplace1')
            .snapshots()
            .listen((snapshot) {
          print("📢 Tổng số documents: ${snapshot.docs.length}");
          for (var doc in snapshot.docs) {
            print("🔥 Dữ liệu: ${doc.data()}");
          }
        });

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Text('Không tìm thấy kết quả');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var document = snapshot.data!.docs[index];
            var name = document['name'];
            var image = document['image'];
            return ListTile(
              title: Text(name),
              leading: Image.network(image),
              subtitle: const Text('Lịch sử'),
            );
          },
        );
      },
    );
  }
}
