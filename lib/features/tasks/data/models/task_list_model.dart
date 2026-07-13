import 'package:json_annotation/json_annotation.dart';

part 'task_list_model.g.dart';

@JsonSerializable()
class TaskListModel {
  final String id;
  final String title;
  final int colorValue;
  final String ownerId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskListModel({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.ownerId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskListModel.fromJson(Map<String, dynamic> json) => _$TaskListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskListModelToJson(this);

  TaskListModel copyWith({
    String? title,
    int? colorValue,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return TaskListModel(
      id: id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      ownerId: ownerId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
