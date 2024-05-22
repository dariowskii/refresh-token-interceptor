import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_auth.freezed.dart';
part 'user_auth.g.dart';

@freezed
class UserAuth with _$UserAuth {
  const factory UserAuth({
    required String token,
    required String refreshToken,
  }) = _UserAuth;

  factory UserAuth.fromJson(Map<String, Object?> json) =>
      _$UserAuthFromJson(json);
}
