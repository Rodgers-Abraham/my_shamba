class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? address;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.address,
  });
}
