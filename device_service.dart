import 'dart:async';
import 'dart:math';

import 'package:hydroshield/core/constants/app_constants.dart';

/// Abstract interface for device services
///
/// Defines the contract for IoT hardware communication.
/// Real implementations (MQTT, REST, etc.) should implement this interface.
abstract class DeviceService {
  /// Stream of tank level readings (0.0 to 1.0)
  Stream<double> get tankLevelStream;

  /// Stream of flow rate readings in liters per minute
  Stream<double> get flowRateStream;

  /// Stream of valve state (true = open, false = closed)
  Stream<bool> get valveStateStream;

  /// Stream of cleaning status
  Stream<CleaningStatus> get cleaningStatusStream;

  /// Start the service and begin listening to device data
  Future<void> start();

  /// Stop the service and disconnect from device
  Future<void> stop();

  /// Manually set the water level (for testing/simulation)
  void setLevel(double level);

  /// Manually set the flow rate (for testing/simulation)
  void setFlowRate(double flowRate);

  /// Manually set the valve state (for testing/simulation)
  void setValveState(bool open);

  /// Manually set the cleaning status (for testing/simulation)
  void setCleaningStatus(CleaningStatus status);
}

/// Mock device service that simulates realistic IoT hardware behavior
class MockDeviceService implements DeviceService {
  final _levelController = StreamController<double>.broadcast();
  final _flowRateController = StreamController<double>.broadcast();
  final _valveStateController = StreamController<bool>.broadcast();
  final _cleaningStatusController = StreamController<CleaningStatus>.broadcast();

  Timer? _updateTimer;
  final Random _random = Random();

  double _currentLevel = 0.7;
  double _currentFlowRate = 8.0;
  bool _currentValveState = true;
  CleaningStatus _currentCleaningStatus = CleaningStatus.idle;

  bool _isFilling = false;
  bool _isDraining = false;
  final double _fillTarget = 1.0;
  final double _drainTarget = 0.2;

  MockDeviceService() {
    _levelController.add(_currentLevel);
    _flowRateController.add(_currentFlowRate);
    _valveStateController.add(_currentValveState);
    _cleaningStatusController.add(_currentCleaningStatus);
  }

  @override
  Stream<double> get tankLevelStream => _levelController.stream;

  @override
  Stream<double> get flowRateStream => _flowRateController.stream;

  @override
  Stream<bool> get valveStateStream => _valveStateController.stream;

  @override
  Stream<CleaningStatus> get cleaningStatusStream =>
      _cleaningStatusController.stream;

  @override
  Future<void> start() async {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      _simulateDeviceCycle();
    });
  }

  @override
  Future<void> stop() async {
    _updateTimer?.cancel();
    await _levelController.close();
    await _flowRateController.close();
    await _valveStateController.close();
    await _cleaningStatusController.close();
  }

  @override
  void setLevel(double level) {
    _currentLevel = level.clamp(0.0, 1.0);
    _levelController.add(_currentLevel);
  }

  @override
  void setFlowRate(double flowRate) {
    _currentFlowRate = flowRate.clamp(0.0, 50.0);
    _flowRateController.add(_currentFlowRate);
  }

  @override
  void setValveState(bool open) {
    _currentValveState = open;
    _valveStateController.add(_currentValveState);
  }

  @override
  void setCleaningStatus(CleaningStatus status) {
    _currentCleaningStatus = status;
    _cleaningStatusController.add(_currentCleaningStatus);
  }

  void _simulateDeviceCycle() {
    _updateLevel();
    _updateFlowRate();
    _updateValveState();
    _updateCleaningStatus();
  }

  void _updateLevel() {
    if (_isFilling) {
      final fillRate = 0.01 * (1 - _currentLevel) * 10;
      _currentLevel = (_currentLevel + fillRate).clamp(0.0, 1.0);
      if (_currentLevel >= _fillTarget) {
        _isFilling = false;
        _isDraining = true;
      }
    } else if (_isDraining) {
      _currentLevel = (_currentLevel - 0.005).clamp(0.0, 1.0);
      if (_currentLevel <= _drainTarget) {
        _isDraining = false;
      }
    } else {
      final variation = (_random.nextDouble() - 0.5) * 0.02;
      _currentLevel = (_currentLevel + variation).clamp(0.0, 1.0);
      // Occasionally start a cycle
      if (_random.nextDouble() < 0.05) {
        _isFilling = _currentLevel < 0.6;
        _isDraining = !_isFilling;
      }
    }
    _levelController.add(_currentLevel);
  }

  void _updateFlowRate() {
    final baseRate = 5.0 + (_random.nextDouble() * 10);
    final variation = (_random.nextDouble() - 0.5) * 2;
    _currentFlowRate = (baseRate + variation).clamp(0.0, 50.0);
    if (_random.nextDouble() < 0.1) {
      _currentFlowRate = 30 + _random.nextDouble() * 20;
    }
    _flowRateController.add(_currentFlowRate);
  }

  void _updateValveState() {
    if (_random.nextDouble() < 0.02) {
      _currentValveState = !_currentValveState;
    }
    _valveStateController.add(_currentValveState);
  }

  void _updateCleaningStatus() {
    switch (_currentCleaningStatus) {
      case CleaningStatus.idle:
        if (_random.nextDouble() < 0.05) {
          _currentCleaningStatus = CleaningStatus.cleaning;
        }
        break;
      case CleaningStatus.cleaning:
        _currentCleaningStatus = CleaningStatus.completed;
        Future.delayed(const Duration(seconds: 3), () {
          _currentCleaningStatus = CleaningStatus.idle;
          _cleaningStatusController.add(_currentCleaningStatus);
        });
        break;
      case CleaningStatus.completed:
        _currentCleaningStatus = CleaningStatus.idle;
        break;
    }
    _cleaningStatusController.add(_currentCleaningStatus);
  }
}