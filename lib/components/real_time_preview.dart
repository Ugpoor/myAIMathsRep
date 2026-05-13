
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RealTimePreview extends StatelessWidget {
  final String content;
  final String lang;

  const RealTimePreview({
    super.key,
    required this.content,
    this.lang = 'cn',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              lang == 'cn' ? '实时预览' : 'Preview',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: content.isEmpty
                  ? Center(
                      child: Text(
                        lang == 'cn' ? '编辑内容后在此预览' : 'Preview will appear here',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Html(
                      data: _convertMarkdownToHtml(content),
                      style: {
                        'h1': Style(
                          fontSize: FontSize(24),
                          fontWeight: FontWeight.bold,
                        ),
                        'h2': Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                        ),
                        'h3': Style(
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.bold,
                        ),
                        'strong': Style(fontWeight: FontWeight.bold),
                        'em': Style(fontStyle: FontStyle.italic),
                        'u': Style(textDecoration: TextDecoration.underline),
                        'p': Style(
                          fontSize: FontSize(16),
                        ),
                        'img': Style(width: Width(100, Unit.percent)),
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _convertMarkdownToHtml(String markdown) {
    String html = markdown
        .replaceAll(RegExp(r'^### (.+)$', multiLine: true), r'<h3>$1</h3>')
        .replaceAll(RegExp(r'^## (.+)$', multiLine: true), r'<h2>$1</h2>')
        .replaceAll(RegExp(r'^# (.+)$', multiLine: true), r'<h1>$1</h1>')
        .replaceAll(r'**([^*]+)**', r'<strong>$1</strong>')
        .replaceAll(r'*([^*]+)*', r'<em>$1</em>')
        .replaceAll(r'__([^_]+)__', r'<u>$1</u>')
        .replaceAll(r'\n', '<br>')
        .replaceAll(RegExp(r'!\[.*?\]\((.+?)\)'), r'<img src="$1" />');

    return '<div>$html</div>';
  }
}
