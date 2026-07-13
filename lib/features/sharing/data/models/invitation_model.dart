import 'package:json_annotation/json_annotation.dart';

part 'invitation_model.g.dart';

enum InvitationStatus { pending, accepted, declined }

@JsonSerializable()
class InvitationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverEmail;
  final String listId;
  final String listTitle;
  final InvitationStatus status;
  final DateTime createdAt;

  InvitationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverEmail,
    required this.listId,
    required this.listTitle,
    this.status = InvitationStatus.pending,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) => _$InvitationModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationModelToJson(this);

  InvitationModel copyWith({
    InvitationStatus? status,
  }) {
    return InvitationModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      receiverEmail: receiverEmail,
      listId: listId,
      listTitle: listTitle,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
