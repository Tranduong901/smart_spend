import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';

class TransactionAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final amount = reader.readInt();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final category = reader.readString();
    final typeIndex = reader.readInt();
    final note = reader.readBool() ? reader.readString() : null;
    final imagePath = reader.readBool() ? reader.readString() : null;
    final isSynced = reader.readBool();
    return TransactionModel(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      type: TransactionType.values[typeIndex],
      note: note,
      imageUrl: imagePath,
      isSynced: isSynced,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.category);
    writer.writeInt(obj.type.index);
    if (obj.note != null) {
      writer.writeBool(true);
      writer.writeString(obj.note!);
    } else {
      writer.writeBool(false);
    }
    if (obj.imageUrl != null) {
      writer.writeBool(true);
      writer.writeString(obj.imageUrl!);
    } else {
      writer.writeBool(false);
    }
    writer.writeBool(obj.isSynced);
  }
}
