import 'package:hive/hive.dart';
import '../../models/category_model.dart';

class CategoryAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final hasIcon = reader.readBool();
    final iconPath = hasIcon ? reader.readString() : null;
    final colorValue = reader.readInt();
    return CategoryModel(
      id: id,
      name: name,
      iconPath: iconPath,
      colorValue: colorValue,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    if (obj.iconPath != null) {
      writer.writeBool(true);
      writer.writeString(obj.iconPath!);
    } else {
      writer.writeBool(false);
    }
    writer.writeInt(obj.colorValue);
  }
}
