import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SchemeWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const SchemeWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<SchemeWebViewScreen> createState() =>
      _SchemeWebViewScreenState();
}

class _SchemeWebViewScreenState extends State<SchemeWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
