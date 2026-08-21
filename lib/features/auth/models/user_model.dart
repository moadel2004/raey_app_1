import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  final int    id;
  final String fullName;
  final String phoneNumber;
  final String role; // 'Farmer' | 'Veterinarian' | 'Admin'

  // ── Role helpers ───────────────────────────────────────────────────────────
  bool get isFarmer       => role == 'Farmer';
  bool get isVeterinarian => role == 'Veterinarian';
  bool get isAdmin        => role == 'Admin';

  String get displayRole {
    switch (role) {
      case 'Farmer':       return 'مزارع';
      case 'Veterinarian': return 'دكتور بيطري';
      case 'Admin':        return 'مدير';
      default:             return role;
    }
  }

  // Backward-compat shims — screens migrated in Stage 3+ will stop using these.
  String get name        => fullName;
  String get phone       => phoneNumber;
  String get uid         => id.toString();
  String get governorate => '';

  // ── Factory constructors ───────────────────────────────────────────────────

  /// Constructs from the auth endpoint `data` field.
  /// Priority (section 2 of migration brief):
  ///   1. data['role'] if the backend has already added it.
  ///   2. [fallbackRole] — pass the role the user selected at register time.
  factory UserModel.fromAuthResponse(
    Map<String, dynamic> data, {
    String? fallbackRole,
  }) {
    return UserModel(
      id:          (data['userId'] as num?)?.toInt() ?? 0,
      fullName:    data['fullName']    as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role:        data['role']        as String? ?? fallbackRole ?? '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          (json['id'] as num?)?.toInt() ?? 0,
      fullName:    json['fullName']    as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role:        json['role']        as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'fullName':    fullName,
    'phoneNumber': phoneNumber,
    'role':        role,
  };

  @override
  List<Object?> get props => [id, fullName, phoneNumber, role];
}
