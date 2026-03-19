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

    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: ExpenseCategory.values[fields[2] as int],
      date: fields[3] as DateTime,
      note: fields[4] as String,
      imagePath: fields[5] as String?,
      isIncome: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category.index)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.isIncome);
  }
}
