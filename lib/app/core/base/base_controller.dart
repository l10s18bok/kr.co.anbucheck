import 'package:get/get.dart';

abstract class BaseController extends FullLifeCycleController
    with FullLifeCycleMixin {
  final _isLoading = false.obs;

  set isLoading(bool value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
