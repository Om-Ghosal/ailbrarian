class Book {
  final String id;
  final String book_name;
  final String author_name;

  Book({
    required this.id,
    required this.book_name,
    required this.author_name,
  });
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      book_name: json['book_name'],
      author_name: json['author_name'],
    );
  }
}
