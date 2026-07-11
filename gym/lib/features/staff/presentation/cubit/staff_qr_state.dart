import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/qr_token.dart';

part 'staff_qr_state.freezed.dart';

@freezed
class StaffQrState with _$StaffQrState {
  const factory StaffQrState.initial() = _Initial;
  const factory StaffQrState.loading() = _Loading;
  const factory StaffQrState.loaded(QrToken qrToken) = _Loaded;
  const factory StaffQrState.error(String message) = _Error;
}
