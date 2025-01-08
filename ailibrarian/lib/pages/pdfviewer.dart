import 'dart:io';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/material.dart';

class PdfViewer extends StatefulWidget {
  final String bookname;
  final String pdfPath;
  const PdfViewer({super.key, required this.bookname, required this.pdfPath});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late PdfControllerPinch controller;
  int totalpages = 0;
  int currentpage = 1;
  @override
  void initState() {
    super.initState();
    controller =
        PdfControllerPinch(document: PdfDocument.openFile(widget.pdfPath));
  }

  String toPascalCaseWithSpaces(String input) {
    return input
        .split(RegExp(r'[_\-]+')) // Split by underscores or hyphens
        .map((part) => part
            .split(' ') // Split further by spaces
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '') // Capitalize the first letter
            .join(' ')) // Join words within a part with spaces
        .join(' '); // Join parts with a single space
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            toPascalCaseWithSpaces(widget.bookname),
            style: TextStyle(color: Color(0xFF9AE19D)),
          ),
          backgroundColor: Color(0xFF2C302E),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF9AE19D)),
            onPressed: () => Navigator.pop(context),
          )),
      body: Column(
        children: [
          Expanded(
              child: PdfViewPinch(
            controller: controller,
            onDocumentLoaded: (document) {
              setState(() {
                totalpages = document.pagesCount;
              });
            },
            onPageChanged: (page) {
              setState(() {
                currentpage = page;
              });
            },
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('$currentpage/$totalpages')],
          )
        ],
      ),
    );
  }
}
