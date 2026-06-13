import 'dart:convert';
import 'package:uuid/uuid.dart';

enum SyncStatus { pending, syncing, completed, failed }

enum EntityType { expense, income, budget, categoryBudget }

enum SyncAction { create, update, delete }

extension SyncStatusExtension on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.completed:
        return 'completed';
      case SyncStatus.failed:
        return 'failed';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value) {
      case 'syncing':
        return SyncStatus.syncing;
      case 'completed':
        return SyncStatus.completed;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }
}

extension EntityTypeExtension on EntityType {
  String get value {
    switch (this) {
      case EntityType.expense:
        return 'expense';
      case EntityType.income:
        return 'income';
      case EntityType.budget:
        return 'budget';
      case EntityType.categoryBudget:
        return 'categoryBudget';
    }
  }

  static EntityType fromString(String value) {
    switch (value) {
      case 'income':
        return EntityType.income;
      case 'budget':
        return EntityType.budget;
      case 'categoryBudget':
        return EntityType.categoryBudget;
      default:
        return EntityType.expense;
    }
  }
}

extension SyncActionExtension on SyncAction {
  String get value {
    switch (this) {
      case SyncAction.create:
        return 'create';
      case SyncAction.update:
        return 'update';
      case SyncAction.delete:
        return 'delete';
    }
  }

  static SyncAction fromString(String value) {
    switch (value) {
      case 'update':
        return SyncAction.update;
      case 'delete':
        return SyncAction.delete;
      default:
        return SyncAction.create;
    }
  }
}

class SyncQueueModel {
  final String id;
  final SyncAction action;
  final EntityType entityType;
  final Map<String, dynamic> payload;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final String entityId;

  const SyncQueueModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.payload,
    required this.syncStatus,
    required this.createdAt,
    required this.entityId,
  });

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as String,
      action: SyncActionExtension.fromString(map['action'] as String),
      entityType: EntityTypeExtension.fromString(map['entityType'] as String),
      payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
      syncStatus:
          SyncStatusExtension.fromString(map['syncStatus'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      entityId: map['entityId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action.value,
      'entityType': entityType.value,
      'payload': jsonEncode(payload),
      'syncStatus': syncStatus.value,
      'createdAt': createdAt.toIso8601String(),
      'entityId': entityId,
    };
  }

  factory SyncQueueModel.create({
    required SyncAction action,
    required EntityType entityType,
    required Map<String, dynamic> payload,
    required String entityId,
  }) {
    return SyncQueueModel(
      id: const Uuid().v4(),
      action: action,
      entityType: entityType,
      payload: payload,
      syncStatus: SyncStatus.pending,
      createdAt: DateTime.now(),
      entityId: entityId,
    );
  }
}
