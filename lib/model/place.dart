// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stour/util/places.dart';
import 'package:collection/collection.dart';
Future<List<Place>> getAllPlaceFood(String collection) async {
  List<Place> results = [];


  try {
    CollectionReference place = FirebaseFirestore.instance.collection(collection);
    QuerySnapshot snapshot = await place.get();

    for (var documentSnapshot in snapshot.docs) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        print(data);

        Place tmpPlace = Place(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          rating: data['rating']?.toString() ?? '0.0', //  double → string
          img: data['image'] ?? '',
          price: data['price'] ?? 0,
          history: data['history'] ?? '',
          duration: data['duration'] ?? 0,
          city: data['city'] ?? '',
          closeTime: data['closetime'] ?? 0,
          district: data['district'] ?? '',
          openTime: data['opentime'] ?? 0,
        );
        // Kiểm tra trùng ID
        if (results.firstWhereOrNull((element) => element.id == tmpPlace.id) == null) {
          results.add(tmpPlace);
        }
      }
    }
  } catch (e) {
    print("❌ Lỗi khi lấy dữ liệu từ Firestore ($collection): $e");

  }

  return results;
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
