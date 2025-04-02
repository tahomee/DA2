// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stour/util/places.dart';
import 'package:collection/collection.dart';

void getAllPlaceFood(String collection) {
  CollectionReference place = FirebaseFirestore.instance.collection(collection);
  place.get().then((QuerySnapshot snapshot) {
    snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        Place tmpPlace = Place(
          id: data['id'],
          name: data['name'],
          address: data['address'],
          rating: data['rating'],
          img: data['image'],
          price: data['price'],
          history: data['history'],
          duration: data['duration'],
          city: data['city'],
          closeTime: data['closetime'],
          district: data['district'],
          openTime: data['opentime'],
        );
        if (collection == 'stourplace1') {
          if (places.firstWhereOrNull((element) => element.id == tmpPlace.id) ==
              null) {
            places.add(tmpPlace);
          }
        } else {
          if (food.firstWhereOrNull((element) => element.id == tmpPlace.id) ==
              null) {
            food.add(tmpPlace);
          }
        }
      }
    });
  });
// }
// void getAllPlaceFood(String collection) async {
//   try {
//     CollectionReference place = FirebaseFirestore.instance.collection(collection);
//     QuerySnapshot snapshot = await place.get();
//
//     print("📢 Tổng số documents trong $collection: ${snapshot.docs.length}");
//
//     for (var documentSnapshot in snapshot.docs) {
//       if (documentSnapshot.exists) {
//         Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//         print("🔥 Dữ liệu từ Firebase: $data");
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
//
//         if (collection == 'stourplace1') {
//           if (places.firstWhereOrNull((element) => element.id == tmpPlace.id) == null) {
//             places.add(tmpPlace);
//             print("✅ Đã thêm địa điểm: ${tmpPlace.name}");
//           }
//         } else {
//           if (food.firstWhereOrNull((element) => element.id == tmpPlace.id) == null) {
//             food.add(tmpPlace);
//             print("✅ Đã thêm món ăn: ${tmpPlace.name}");
//           }
//         }
//       }
//     }
//   } catch (e) {
//     print("❌ Lỗi khi lấy dữ liệu từ Firestore ($collection): $e");
//   }
 }

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
