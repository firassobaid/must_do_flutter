// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskListModel _$TaskListModelFromJson(Map<String, dynamic> json) =>
    TaskListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
      ownerId: json['ownerId'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskListModelToJson(TaskListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'colorValue': instance.colorValue,
      'ownerId': instance.ownerId,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
