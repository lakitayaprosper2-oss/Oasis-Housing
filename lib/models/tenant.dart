import 'payment_record.dart';

class Tenant {
  final String id;
  String name;
  List<String> phones;
  String tribe;
  String gender;
  int? age;
  double rent;
  int intervalMonths;
  String startDate; // yyyy-MM-dd, date rent started
  String? docPath;
  String? docName;

  // Payment tracking: the due-date schedule only advances once a cycle is
  // fully settled (see AppState.addPayment). This mirrors the web version's
  // logic so an early or partial payment never shifts the fixed schedule.
  String? lastPaidDueDate; // yyyy-MM-dd, last fully-settled cycle's due date
  double amountPaidThisCycle;
  List<PaymentRecord> payments;

  Tenant({
    required this.id,
    required this.name,
    required this.phones,
    this.tribe = '',
    this.gender = '',
    this.age,
    required this.rent,
    required this.intervalMonths,
    required this.startDate,
    this.docPath,
    this.docName,
    this.lastPaidDueDate,
    this.amountPaidThisCycle = 0,
    List<PaymentRecord>? payments,
  }) : payments = payments ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phones': phones,
        'tribe': tribe,
        'gender': gender,
        'age': age,
        'rent': rent,
        'intervalMonths': intervalMonths,
        'startDate': startDate,
        'docPath': docPath,
        'docName': docName,
        'lastPaidDueDate': lastPaidDueDate,
        'amountPaidThisCycle': amountPaidThisCycle,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as String,
        name: json['name'] as String,
        phones: (json['phones'] as List).map((e) => e as String).toList(),
        tribe: json['tribe'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        age: json['age'] as int?,
        rent: (json['rent'] as num).toDouble(),
        intervalMonths: json['intervalMonths'] as int,
        startDate: json['startDate'] as String,
        docPath: json['docPath'] as String?,
        docName: json['docName'] as String?,
        lastPaidDueDate: json['lastPaidDueDate'] as String?,
        amountPaidThisCycle: (json['amountPaidThisCycle'] as num?)?.toDouble() ?? 0,
        payments: (json['payments'] as List? ?? [])
            .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
