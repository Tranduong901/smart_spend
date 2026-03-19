import 'package:hive/hive.dart';
import 'package:smart_spend/models/transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  static const int adapterTypeId = 1;

  @override
  final int typeId = adapterTypeId;

  @override
  Transaction read(BinaryReader reader) {
    final numberOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int index = 0; index < numberOfFields; index++)
        reader.readByte(): reader.read(),
    };

    final rawAmount = fields[1];
    final amount = rawAmount is num ? rawAmount.toDouble() : 0.0;

    final rawCategory = fields[2];
    final categoryName = _decodeCategoryName(rawCategory);

    final note = (fields[4] as String?) ?? 'Không có ghi chú';
    final title = (fields[7] as String?)?.trim();

    return Transaction(
      id: fields[0] as String,
      amount: amount,
      categoryName: categoryName,
      date: fields[3] as DateTime,
      note: note,
      imagePath: fields[5] as String?,
      isIncome: (fields[6] as bool?) ?? false,
      title: (title == null || title.isEmpty) ? categoryName : title,
    );
  }

  String _decodeCategoryName(dynamic rawCategory) {
    if (rawCategory is String && rawCategory.trim().isNotEmpty) {
      return rawCategory;
    }

    if (rawCategory is int) {
      switch (rawCategory) {
        case 0:
          return 'Ăn uống';
        case 1:
          return 'Di chuyển';
        case 2:
          return 'Shopping';
        default:
          return 'Khác';
      }
    }

    return 'Khác';
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.isIncome)
      ..writeByte(7)
      ..write(obj.title);
  }
}
