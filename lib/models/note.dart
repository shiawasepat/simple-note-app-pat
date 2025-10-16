import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final String title;
  final String body;

  const Note({
    required this.id,
    required this.title,
    required this.body,
  });

  Note copyWith({
    int? id,
    String? title,
    String? body,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'title': title,
      'body': body,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['ID'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, body];
}
