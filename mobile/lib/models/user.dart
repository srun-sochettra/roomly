class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const AppUser({required this.id, required this.name, required this.email, required this.role});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
      );

  String get initials => name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
}
