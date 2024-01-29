class Message {
  final String id;
  final String uid;
  final String username;
  final DateTime timestamp;
  final String selectedImagePath;
  final String message;

  Message({
    required this.id,
    required this.uid,
    required this.username,
    required this.timestamp,
    required this.selectedImagePath,
    required this.message,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['_id'] ?? '',
        uid: json['uid'] ?? '',
        username: json['username'] ?? '',
        timestamp: DateTime.parse(json['timestamp'] ?? ''),
        selectedImagePath: json['selectedImagePath'] ?? '',
        message: json['message'] ?? '',
    );
  }
}

