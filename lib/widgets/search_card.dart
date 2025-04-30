import 'package:flutter/material.dart';
import 'package:stour/model/place.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  final TextEditingController _searchControl = TextEditingController();
  String searchQuery = ""; // Variable to store search query

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextField with decoration
        Container(
          height: MediaQuery.of(context).size.height * 0.1, // Adjusting the height of the search bar
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: TextField(
            onChanged: (text) {
              setState(() {
                searchQuery = text;
              });
            },
            style: const TextStyle(
              fontSize: 15.0,
              color: Color.fromARGB(255, 35, 52, 10),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: "Nhập từ khóa để tìm kiếm...",
              prefixIcon: const Icon(
                Icons.search,
                color: Color.fromARGB(255, 35, 52, 10),
              ),
              suffixIcon: const Icon(
                Icons.filter_list,
                color: Color.fromARGB(255, 35, 52, 10),
              ),
              hintStyle: const TextStyle(
                fontSize: 15.0,
                color: Color.fromARGB(255, 35, 52, 10),
              ),
            ),
            maxLines: 1,
            controller: _searchControl,
          ),
        ),
        // Display search results if search query is not empty
        if (searchQuery.isNotEmpty)
          Expanded( // THÊM Expanded ở đây
            child: SearchByNameWidget(searchQuery),
          ),      ],
    );
  }
}