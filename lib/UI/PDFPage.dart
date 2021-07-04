import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFPage extends StatelessWidget {
  final String url;
  final String name;
  PDFPage({this.url, this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
