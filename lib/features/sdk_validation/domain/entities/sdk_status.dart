/// Entity domain layer untuk SDK status.
class SdkStatus {
  final int sdkInt;
  final bool isWebViewAvailable;

  const SdkStatus({
    required this.sdkInt,
    required this.isWebViewAvailable,
  });

  bool get isCompatible => sdkInt >= 24 && isWebViewAvailable;
}
