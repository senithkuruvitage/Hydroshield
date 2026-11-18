import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Constants for HydroShield application

/// Tank states and thresholds
enum TankState { full, normal, low, critical }

extension TankStateExtension on TankState {
  String get label {
    switch (this) {
      case TankState.full:
        return 'Full';
      case TankState.normal:
        return 'Normal';
      case TankState.low:
        return 'Low';
      case TankState.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case TankState.full:
        return const Color(0xFF00897B); // Teal
      case TankState.normal:
        return const Color(0xFF0288D1); // Blue
      case TankState.low:
        return const Color(0xFFBF360C); // Amber/Orange
      case TankState.critical:
        return const Color(0xFFC62828); // Red
    }
  }

  String get labelWithEmoji {
    switch (this) {
      case TankState.full:
        return '🟢 Full';
      case TankState.normal:
        return '🔵 Normal';
      case TankState.low:
        return '🟠 Low';
      case TankState.critical:
        return '🔴 Critical';
    }
  }
}

/// Water level percentages for each state
class LevelPercentages {
  static const double full = 100.0;
  static const double normal = 75.0;
  static const double low = 25.0;
  static const double critical = 10.0;
}

/// Notification thresholds
class NotificationThresholds {
  static const double lowLevel = 25.0; // percent
  static const double criticalLevel = 10.0; // percent
}

/// Feature keys for shared preferences
class SharedPrefsKeys {
  static const String lastTankLevel = 'last_tank_level';
  static const String lastTankTime = 'last_tank_time';
  static const String lastCleaningTime = 'last_cleaning_time';
  static const String daysSinceCleaning = 'days_since_cleaning';
  static const String cleaningStatus = 'cleaning_status';
  static const String leakThreshold = 'leak_threshold';
  static const String leakDuration = 'leak_duration';
  static const String renterCount = 'renter_count';
  static const String userRole = 'user_role';
  static const String selectedPricePerLiter = 'selected_price_per_liter';
  static const String governmentWaterRate = 'government_water_rate';
}

/// Cleaning status for tank cleaning cycle
enum CleaningStatus { idle, cleaning, completed }

/// Role enum
enum UserRole { owner, renter }

extension RoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.renter:
        return 'Renter';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.person;
      case UserRole.renter:
        return Icons.person_outline;
    }
  }
}

/// Mock device states
class MockDeviceStates {
  static const double minLevel = 0.0;
  static const double maxLevel = 1.0;
  static const double minFlowRate = 0.0; // liters per minute
  static const double maxFlowRate = 50.0; // liters per minute
}

/// Tank capacity in liters (typical residential tank)
class TankCapacity {
  static const double typical = 1000.0; // liters
}

/// Time durations
class TimeDurations {
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration waveAnimationDuration = Duration(milliseconds: 2000);
  static const Duration pulseDuration = Duration(seconds: 2);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
}

/// Mathematical constants
double get kPi => math.pi;
double get kTwoPi => math.pi * 2;