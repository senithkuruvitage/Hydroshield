import 'dart:async';

import '../../core/constants/app_constants.dart';
import 'device_service.dart';

/// Placeholder MQTT device service for future ESP32/MQTT integration.
/// Currently mirrors mock behavior so the app remains buildable and swappable.
class MqttDeviceService implements DeviceService {
  final _tankLevelController = StreamController<double>.broadcast();
  final _flowRateController = StreamController<double>.broadcast();
  final _valveStateController = StreamController<bool>.broadcast();
  final _cleaningStatusController = StreamController<CleaningStatus>.broadcast();

  double _level = 0.7;
  double _flowRate = 8.0;
  bool _valveOpen = true;
  CleaningStatus _cleaningStatus = CleaningStatus.idle;

  @override
  Stream<double> get tankLevelStream => _tankLevelController.stream;
  @override
  Stream<double> get flowRateStream => _flowRateController.stream;
  @override
  Stream<bool> get valveStateStream => _valveStateController.stream;
  @override
  Stream<CleaningStatus> get cleaningStatusStream =>
      _cleaningStatusController.stream;

  @override
  Future<void> start() async {
    _tankLevelController.add(_level);
    _flowRateController.add(_flowRate);
    _valveStateController.add(_valveOpen);
    _cleaningStatusController.add(_cleaningStatus);
  }

  @override
  Future<void> stop() async {
    await _tankLevelController.close();
    await _flowRateController.close();
    await _valveStateController.close();
    await _cleaningStatusController.close();
  }

  @override
  void setLevel(double level) {
    _level = level.clamp(0.0, 1.0);
    _tankLevelController.add(_level);
  }

  @override
  void setFlowRate(double flowRate) {
    _flowRate = flowRate.clamp(0.0, 100.0);
    _flowRateController.add(_flowRate);
  }

  @override
  void setValveState(bool open) {
    _valveOpen = open;
    _valveStateController.add(_valveOpen);
  }

  @override
  void setCleaningStatus(CleaningStatus status) {
    _cleaningStatus = status;
    _cleaningStatusController.add(_cleaningStatus);
  }
}