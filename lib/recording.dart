import 'package:hive/hive.dart';

part 'recording.g.dart';

@HiveType(typeId: 0)
class Recording extends HiveObject {
  @HiveField(0)
  String filePath;

  @HiveField(1)
  String format;

  @HiveField(2)
  int duration;

  @HiveField(3)
  DateTime createdAt;

  Recording({
    required this.filePath,
    required this.format,
    required this.duration,
    required this.createdAt,
  });
}
