import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/flavors_creator.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/flavors_info_manager.dart';

import 'flavor_model.dart';

///Handles the flavor addition to the app

class BaseFlavorManager {
  FlavorCreator _flavorCreator = FlavorCreator();
  FlavorInfoManager _flavorInfoManager = FlavorInfoManager();
  Future<FlavorModel?> getFlavorInfomation({
    required String package,
    FlavorModel? model,
  }) async {
    return await _flavorInfoManager.getFlavorInfomation(
        package: package, model: model);
  }

  Future<void> createFlavor(FlutterAppDetails appDetails) async {
    return await _flavorCreator.createFlavor(appDetails);
  }

  Future<void> modifyNewDestinationFiles(FlutterAppDetails appDetails) async {
    return await _flavorCreator.modifyNewDestinationFiles(
        appDetails: appDetails);
  }
}
