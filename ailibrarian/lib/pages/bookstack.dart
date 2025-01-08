import 'package:ailibrarian/pages/gridtiles_bookstack.dart';
import 'package:ailibrarian/pages/models/book.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Bookstack extends StatefulWidget {
  const Bookstack({super.key});

  @override
  State<Bookstack> createState() => _BookstackState();
}

class _BookstackState extends State<Bookstack> {
  List imgPaths = [];
  void innitState() {
    super.initState();
    fetchbooks();
  }

  Future<List> fetchbooks() async {
    //demo data
    var url = Uri.http('192.168.0.157:8000', '/fetchbooks');
    var response = await http.get(url);
    var jsonData = jsonDecode(response.body);

    for (var book in jsonData) {
      getimages(book['id']);
      // books.add(book);
    }

    // print(books.length);
    // print(books);
    // return jsonDecode(response.body);
    return jsonDecode(response.body);
  }

  Future<void> getimages(String bookid) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$bookid.jpg';
    print(filePath);
    imgPaths.add(filePath);
    final file = File(filePath);

    if (file.existsSync()) {
    } else {
      var url = Uri.http('192.168.0.157:8000', '/image', {'book_id': bookid});
      var response = await http.post(
        url,
      );
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  Future<void> getbook(String bookid) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$bookid.pdf';

    final file = File(filePath);

    if (file.existsSync()) {
      print('book is already downloaded');
    } else {
      var url = Uri.http('192.168.0.157:8000', '/getbook', {'book_id': bookid});
      var response = await http.post(
        url,
      );
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  Future<void> deleteBook(String bookid) async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfPath = '${directory.path}/$bookid.pdf';

    final file = File(pdfPath);
    await file.delete();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth < 600 ? 8.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF909590),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: FutureBuilder<List>(
          future: fetchbooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No books found.'));
            }

            final books = snapshot.data!;

            return FutureBuilder<Directory>(
              future: getApplicationDocumentsDirectory(),
              builder: (context, directorySnapshot) {
                if (directorySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (directorySnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${directorySnapshot.error}'),
                  );
                }

                final directoryPath = directorySnapshot.data!.path;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    mainAxisSpacing: 10, // Vertical spacing between grid items
                    crossAxisSpacing: 10,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final pdfPath = '$directoryPath/${books[index]['id']}.pdf';

                    return GridTile(
                      child: MyGridtile(
                        id: books[index]['id'],
                        author: books[index]['author_name'],
                        bookname: books[index]['book_name'],
                        imgPath: imgPaths[index],
                        getbook: getbook,
                        pdfPath: pdfPath,
                        deleteBook: deleteBook,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
