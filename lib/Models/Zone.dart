class Zone {
  final String id;
  final String uid;
  final String fullname;
  final String username;
  final String zoneTitle;
  final String avatar;
  final String selectedImagePath;
  final String zoneDescription;
  final List<String> selectedTags;
  final DateTime timestamp;
  final List<Member> members;

  Zone({
    required this.id,
    required this.uid,
    required this.fullname,
    required this.username,
    required this.zoneTitle,
    required this.avatar,
    required this.selectedImagePath,
    required this.zoneDescription,
    required this.selectedTags,
    required this.timestamp,
    required this.members,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      fullname: json['fullname'] ?? '',
      username: json['username'] ?? '',
      zoneTitle: json['zoneTitle'] ?? '',
      avatar: json['avatar'] ?? '',
      selectedImagePath: json['selectedImagePath'] ?? '',
      zoneDescription: json['zoneDescription'] ?? '',
      selectedTags: (json['selectedTags'] as String?)
          ?.split(', ')
          .where((tag) => tag.isNotEmpty)
          .toList() ?? [],
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
      members: List<Member>.from((json['data']['members'] as List<dynamic>? ?? [])
          .map((member) => Member.fromJson(member))),
    );
  }
}

class Member {
  final String fullname;
  final String selectedImagePath;
  final String uid;
  final String username;

  Member({
    required this.fullname,
    required this.selectedImagePath,
    required this.uid,
    required this.username,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      fullname: json['fullname'] ?? '',
      selectedImagePath: json['selectedImagePath'] ?? '',
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
    );
  }
}
