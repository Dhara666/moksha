class FlutterWidgetData {
  final String text;
  // final String author;

  FlutterWidgetData(this.text);
  // this.author
  FlutterWidgetData.fromJson(Map<String, dynamic> json)
      : text = json['text'];
        // author = json['author']

  Map<String, dynamic> toJson() =>
    {
      'text': text,
      // 'author': author,
    };
}