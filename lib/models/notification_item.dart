class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'info' | 'success' | 'warning'
  final String link;
  final bool isRead;
  final String createdAt;
  final String? icon;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    this.link = '/dashboard',
    this.isRead = false,
    this.createdAt = 'Baru saja',
    this.icon,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Pemberitahuan',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      link: json['link']?.toString() ?? '/dashboard',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt']?.toString() ?? 'Baru saja',
      icon: json['icon']?.toString(),
    );
  }

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      link: link,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      icon: icon,
    );
  }
}
