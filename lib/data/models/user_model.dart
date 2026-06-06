import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String uid;

  UserModel({
    required this.uid,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    super.address,
  }) : super(
          id: uid,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
