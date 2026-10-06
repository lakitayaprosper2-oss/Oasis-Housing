import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/house.dart';
import '../models/payment_record.dart';
import '../models/tenant.dart';
import '../services/notification_service.dart';
import '../utils/rent_calculator.dart';

class AppState extends ChangeNotifier {
  String username = 'admin';
  String password = 'oasis2026';
  bool isLoggedIn = false;

  bool isLoaded = false;

  final List<House> houses = [];
  StreamSubscription<QuerySnapshot>? _housesSubscription;

  // ---------------- Auth ----------------
  bool login(String u, String p) {
    if (u == username && p == password) {
      isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void updateCredentials(String u, String p) {
    username = u;
    password = p;
    notifyListeners();
    _saveCredentials();
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_username', username);
    await prefs.setString('admin_password', password);
  }

  // ---------------- Persistence & Firestore Sync ----------------
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('admin_username') ?? username;
    password = prefs.getString('admin_password') ?? password;

    final hasSeeded = prefs.getBool('has_seeded_demo_data') ?? false;

    // Listen to real-time changes from Firestore (multi-device sync)
    _housesSubscription?.cancel();
    _housesSubscription = FirebaseFirestore.instance.collection('houses').snapshots().listen(
      (snapshot) async {
        houses.clear();
        for (final doc in snapshot.docs) {
          try {
            houses.add(House.fromJson(doc.data()));
          } catch (_) {}
        }

        // If Firestore is empty on first-ever launch, seed demo data once.
        // Once seeded, deleting all houses will keep them deleted instead of re-seeding.
        if (houses.isEmpty && !hasSeeded) {
          await prefs.setBool('has_seeded_demo_data', true);
          await _seedToFirestore();
        } else {
          isLoaded = true;
          notifyListeners();
          _checkAndTriggerAutomaticAdminNotification();
          _scheduleAllTenantNotifications();
        }
      },
      onError: (_) {
        // Fallback if offline or firestore error
        isLoaded = true;
        notifyListeners();
      },
    );
  }

  Future<void> _seedToFirestore() async {
    // No demo houses created; app starts completely empty.
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _syncHouseToFirestore(House house) async {
    await FirebaseFirestore.instance.collection('houses').doc(house.id).set(house.toJson());
  }

  Future<void> _deleteHouseFromFirestore(String houseId) async {
    await FirebaseFirestore.instance.collection('houses').doc(houseId).delete();
  }

  // ---------------- Notifications ----------------
  Future<void> _checkAndTriggerAutomaticAdminNotification() async {
    final fourteenDayTenants = <String>[];
    for (final h in houses) {
      for (final t in h.tenants) {
        final info = RentCalculator.compute(t);
        if (info.daysLeft == 14 && !info.overdue) {
          fourteenDayTenants.add(t.name);
        }
      }
    }

    if (fourteenDayTenants.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = RentCalculator.formatDate(DateTime.now());
      final lastNotified = prefs.getString('last_admin_notification_date');

      if (lastNotified != todayStr) {
        await prefs.setString('last_admin_notification_date', todayStr);
        await NotificationService.instance.showAdminRentDueNotification(
          count: fourteenDayTenants.length,
          tenantNamesSummary: fourteenDayTenants.join(', '),
        );
      }
    }
  }

  Future<void> _scheduleAllTenantNotifications() async {
    for (final h in houses) {
      for (final t in h.tenants) {
        final info = RentCalculator.compute(t);
        final tenantIdInt = t.id.hashCode;
        await NotificationService.instance.scheduleTenant14DayNotification(
          id: tenantIdInt,
          tenantName: t.name,
          houseLocation: h.location,
          dueDate: info.nextDate,
        );
      }
    }
  }

  // ---------------- Houses ----------------
  void addHouse(String location) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final house = House(id: newId, location: location);
    _syncHouseToFirestore(house);
  }

  void updateHouse(String houseId, String location) {
    final h = houses.firstWhere((x) => x.id == houseId);
    h.location = location;
    _syncHouseToFirestore(h);
  }

  void deleteHouse(String houseId) {
    _deleteHouseFromFirestore(houseId);
  }

  // ---------------- Tenants ----------------
  void addTenant(String houseId, Tenant tenant) {
    final h = houses.firstWhere((x) => x.id == houseId);
    h.tenants.add(tenant);
    _syncHouseToFirestore(h);
  }

  void updateTenant(String houseId, Tenant updated) {
    final h = houses.firstWhere((x) => x.id == houseId);
    final idx = h.tenants.indexWhere((t) => t.id == updated.id);
    if (idx != -1) h.tenants[idx] = updated;
    _syncHouseToFirestore(h);
  }

  void deleteTenant(String houseId, String tenantId) {
    final h = houses.firstWhere((x) => x.id == houseId);
    final t = h.tenants.firstWhere((x) => x.id == tenantId, orElse: () => Tenant(id: '', name: '', phones: [], rent: 0, intervalMonths: 1, startDate: ''));
    if (t.id.isNotEmpty) {
      NotificationService.instance.cancelNotification(t.id.hashCode);
    }
    h.tenants.removeWhere((t) => t.id == tenantId);
    _syncHouseToFirestore(h);
  }

  // ---------------- Payments ----------------
  void addPayment(
    String houseId,
    String tenantId, {
    required String date,
    required double amount,
    String? receiptPath,
    String? receiptName,
  }) {
    final h = houses.firstWhere((x) => x.id == houseId);
    final t = h.tenants.firstWhere((x) => x.id == tenantId);

    final info = RentCalculator.compute(t);
    t.amountPaidThisCycle += amount;
    double remaining = t.rent - t.amountPaidThisCycle;
    if (remaining < 0) remaining = 0;

    if (remaining <= 0) {
      t.lastPaidDueDate = RentCalculator.formatDate(info.nextDate);
      t.amountPaidThisCycle = 0;
    }

    t.payments.add(PaymentRecord(
      date: date,
      amount: amount,
      remaining: remaining,
      receiptPath: receiptPath,
      receiptName: receiptName,
    ));

    _syncHouseToFirestore(h);
  }

  // ---------------- Derived counts ----------------
  int get totalHouses => houses.length;
  int get totalTenants => houses.fold(0, (a, h) => a + h.tenants.length);
  int get overdueCount => houses.fold(
        0,
        (a, h) => a + h.tenants.where((t) => RentCalculator.compute(t).overdue).length,
      );
}
