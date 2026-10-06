class PaymentRecord {
  final String date; // yyyy-MM-dd
  final double amount;
  final double remaining; // balance left on this cycle after this payment
  final String? receiptPath;
  final String? receiptName;

  PaymentRecord({
    required this.date,
    required this.amount,
    required this.remaining,
    this.receiptPath,
    this.receiptName,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
        'remaining': remaining,
        'receiptPath': receiptPath,
        'receiptName': receiptName,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        date: json['date'] as String,
        amount: (json['amount'] as num).toDouble(),
        remaining: (json['remaining'] as num).toDouble(),
        receiptPath: json['receiptPath'] as String?,
        receiptName: json['receiptName'] as String?,
      );
}
