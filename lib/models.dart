class UserAuthRequest {
  final String username;

  UserAuthRequest({
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}

class UserAuthResponse {
  final String token;
  final String refreshToken;

  UserAuthResponse({
    required this.token,
    required this.refreshToken,
  });

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}

class TokenRequest {
  final String token;

  TokenRequest({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

class HomeResponse {
  final String data;

  HomeResponse({
    required this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      data: json['data'],
    );
  }
}
