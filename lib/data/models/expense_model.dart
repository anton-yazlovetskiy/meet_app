import '../../domain/index.dart';

class ReceiptModel extends Receipt {
  ReceiptModel({
    required super.id,
    required super.expenseId,
    required super.fileUrl,
    required super.uploadedBy,
    required super.createdAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      fileUrl: json['fileUrl'] as String,
      uploadedBy: json['uploadedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReceiptModel.fromEntity(Receipt receipt) {
    return ReceiptModel(
      id: receipt.id,
      expenseId: receipt.expenseId,
      fileUrl: receipt.fileUrl,
      uploadedBy: receipt.uploadedBy,
      createdAt: receipt.createdAt,
    );
  }
}

class ExpenseItemModel extends ExpenseItem {
  ExpenseItemModel({
    required super.id,
    required super.eventId,
    required super.authorId,
    required super.description,
    required super.amount,
    required super.createdAt,
    required super.contributors,
    required super.receipts,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      authorId: json['authorId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      contributors: Map<String, double>.from(
        (json['contributors'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      receipts: (json['receipts'] as List?)?.map((e) => ReceiptModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'authorId': authorId,
      'description': description,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'contributors': contributors,
      'receipts': receipts.map((e) => (e as ReceiptModel).toJson()).toList(),
    };
  }

  factory ExpenseItemModel.fromEntity(ExpenseItem expenseItem) {
    return ExpenseItemModel(
      id: expenseItem.id,
      eventId: expenseItem.eventId,
      authorId: expenseItem.authorId,
      description: expenseItem.description,
      amount: expenseItem.amount,
      createdAt: expenseItem.createdAt,
      contributors: expenseItem.contributors,
      receipts: expenseItem.receipts,
    );
  }
}
