import 'dart:io';
import 'package:ailibrarian/pages/pdfviewer.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class MyGridtile extends StatefulWidget {
  final String id;
  final String author;
  final String bookname;
  final String imgPath;
  final String pdfPath;
  final Future<void> Function(String) getbook;
  final Future<void> Function(String) deleteBook;

  const MyGridtile(
      {super.key,
      required this.id,
      required this.author,
      required this.bookname,
      required this.imgPath,
      required this.getbook,
      required this.pdfPath,
      required this.deleteBook});

  @override
  State<MyGridtile> createState() => _MyGridtileState();
}

class _MyGridtileState extends State<MyGridtile> {
  @override
  Widget build(BuildContext context) {
    bool _buttonWidget = !File(widget.pdfPath).existsSync();

    return Container(
      height: 300,
      width: 190,
      decoration: BoxDecoration(
        color: Color(0xFF2C302E),
        // Background color
        borderRadius: BorderRadius.circular(20), // Rounded edges
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(widget.imgPath),
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            widget.author,
            style: TextStyle(
                color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13),
          ),
          Center(
            child: _buttonWidget
                ? ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        widget.getbook(widget.id);
                      });

                      await widget.getbook(widget.id);

                      setState(() {
                        _buttonWidget = !File(widget.pdfPath).existsSync();
                      });
                    },
                    label: Text(
                      'Install',
                      style: TextStyle(
                          color: Color(0xFF9AE19D),
                          fontWeight: FontWeight.bold),
                    ),
                    icon: Icon(Icons.download),
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.grey,
                        backgroundColor: Color(0xFF474A48),
                        iconColor: Color(0xFF9AE19D)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewer(
                                bookname: widget.bookname,
                                pdfPath: widget.pdfPath,
                              ),
                            ),
                          );
                        },
                        label: Text(
                          'Read',
                          style: TextStyle(
                              color: Color(0xFF9AE19D),
                              fontWeight: FontWeight.bold),
                        ),
                        icon: Icon(Icons.read_more),
                        style: ElevatedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          backgroundColor: Color(0xFF474A48),
                          iconColor: Color(0xFF9AE19D),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              widget.deleteBook(widget.id);
                            });
                            await widget.deleteBook(widget.id);
                            setState(() {
                              _buttonWidget =
                                  !File(widget.pdfPath).existsSync();
                            });
                          },
                          child: Icon(Icons.delete_forever_rounded),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF474A48),
                            iconColor: Colors.red[400],
                            // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
