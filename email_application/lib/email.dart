class Email {
  final String docId;
  final String contact;
  final String title;
  final String message;
  final String received;
  bool isSelected;
  bool isNoted;

  Email({
    required this.docId,
    required this.contact,
    required this.title,
    required this.message,
    required this.received,
    this.isSelected = false,
    this.isNoted = false,
  });
}
