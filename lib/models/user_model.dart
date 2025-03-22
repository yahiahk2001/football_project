import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? identifier;
  final String? profilePicture;
  final String role;
  final String? bio;
  final String? favoriteClub;


  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.identifier,
    this.profilePicture,
    required this.role,
    this.bio,
    this.favoriteClub,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['user_id'],
    email: json['email'],
    username: json['username'],
    identifier: json['identifier'],
    profilePicture: json['profile_picture'],
    role: json['role'],
    bio: json['bio'],
    favoriteClub: json['favoriteClub'],

  );

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'email': email,
    'username': username,
    'identifier': identifier,
    'profile_picture': profilePicture,
    'role': role,
    'bio': bio,
    'favoriteClub': favoriteClub,

  };

  String? getProfileImageUrl() {
    if (profilePicture != null) {
      return Supabase.instance.client.storage
          .from('images')
          .getPublicUrl('profiles/${profilePicture!.split('/').last}');
    }
    return null;
  }

  UserModel copyWith({
    String? username,
    String? identifier,
    String? bio,
    String? favoriteClub,
    String? profilePicture,
  }) {
    return UserModel(
      id: id,
      email: email,
      username: username ?? this.username,
      identifier: identifier ?? this.identifier,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role,
      bio: bio ?? this.bio,
      favoriteClub: favoriteClub ?? this.favoriteClub,

    );
  }
}