import 'tenant.dart';

class House {
  final String id;
  String location;
  List<Tenant> tenants;

  House({
    required this.id,
    required this.location,
    List<Tenant>? tenants,
  }) : tenants = tenants ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'location': location,
        'tenants': tenants.map((t) => t.toJson()).toList(),
      };

  factory House.fromJson(Map<String, dynamic> json) => House(
        id: json['id'] as String,
        location: json['location'] as String,
        tenants: (json['tenants'] as List? ?? [])
            .map((e) => Tenant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
