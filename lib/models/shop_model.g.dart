// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopOwnerAdapter extends TypeAdapter<ShopOwner> {
  @override
  final int typeId = 3;

  @override
  ShopOwner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopOwner(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      googleId: fields[3] as String?,
      avatar: fields[4] as String?,
      role: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShopOwner obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.googleId)
      ..writeByte(4)
      ..write(obj.avatar)
      ..writeByte(5)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopOwnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShopCategoryAdapter extends TypeAdapter<ShopCategory> {
  @override
  final int typeId = 4;

  @override
  ShopCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopCategory(
      id: fields[0] as int,
      name: fields[1] as String,
      icon: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShopCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShopAdapter extends TypeAdapter<Shop> {
  @override
  final int typeId = 2;

  @override
  Shop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shop(
      id: fields[0] as int,
      userId: fields[1] as int,
      categoryId: fields[2] as int,
      name: fields[3] as String,
      contactInfo: fields[4] as String?,
      location: fields[5] as String?,
      owner: fields[6] as ShopOwner,
      category: fields[7] as ShopCategory,
      images: (fields[8] as List?)?.cast<String>(),
      loyaltyCards: (fields[9] as List?)?.cast<LoyaltyCard>(),
      shopLocations: (fields[10] as List?)?.cast<ShopLocation>(),
    );
  }

  @override
  void write(BinaryWriter writer, Shop obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.contactInfo)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.owner)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.loyaltyCards)
      ..writeByte(10)
      ..write(obj.shopLocations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
