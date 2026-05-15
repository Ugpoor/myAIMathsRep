
class Student {
  final int? id;
  final String name;
  final String studentId;
  final String deviceId;
  final int? createdAt;

  Student({
    this.id,
    required this.name,
    required this.studentId,
    required this.deviceId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'device_id': deviceId,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      studentId: map['student_id'],
      deviceId: map['device_id'],
      createdAt: map['created_at'],
    );
  }
}