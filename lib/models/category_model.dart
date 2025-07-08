import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? imagePath;

  Category({
    required this.id,
    required this.name,
    this.imagePath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_path': imagePath,
  };
}
