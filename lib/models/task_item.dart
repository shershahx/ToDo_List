class TaskItem {
  final String title;
  final bool done;
  final DateTime? dueDate;
  final String category;

  const TaskItem({
    required this.title,
    this.done = false,
    this.dueDate,
    this.category = 'none',
  });

  TaskItem copyWith({
    String? title,
    bool? done,
    DateTime? dueDate,
    String? category,
  }) {
    return TaskItem(
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        title: json['title'] as String,
        done: json['done'] as bool,
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        category: (json['category'] as String?) ?? 'none',
      );
}
