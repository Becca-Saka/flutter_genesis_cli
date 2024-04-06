import 'dart:io';

import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/modules/generators/yaml/yaml_generator.dart';
import 'package:flutter_genesis/src/shared/extensions/lists.dart';
import 'package:flutter_genesis/src/shared/logger.dart';
import 'package:flutter_genesis/src/shared/validators.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import 'flavor_model.dart';

///Handles the flavor addition to the app

class FlavorInfoManager {
  FlutterGenesisCli process = FlutterGenesisCli();
  YamlGenerator yamlGenerator = YamlGenerator();

  Future<FlavorModel?> getFlavorInfomation({
    required String package,
    FlavorModel? model,
  }) async {
    bool response = false;
    if (model == null || model.environmentOptions.isEmpty) {
      response = process.getConfirmation(
        prompt: 'Do you want app flavors?',
        defaultValue: false,
      );
    } else {
      response = true;
    }
    if (response) {
      if (model == null || model.environmentOptions.isEmpty) {
        final selectedFlavors = _getFlavors();
        model = FlavorModel(
          environmentOptions: selectedFlavors,
        );
        m('You chose flavor(s): $selectedFlavors');
      }
      final selectedFlavors = model.environmentOptions;
      model.name = _getFlavorAppName(selectedFlavors);
      model.packageId = _getFlavorAppId(selectedFlavors, package);
      model.imagePaths = await _getFlavorImage(selectedFlavors);
      model.versionNameSuffix = _getFlavorVersionNameSuffix(selectedFlavors);
      model.versionCode = _getFlavorVersionCodeSuffix(selectedFlavors);
      model.minSdkVersion = _getFlavorMinSdkVersionSuffix(selectedFlavors);
      model.signingConfig = _getSigningConfig(selectedFlavors);
      model.resValues = _getResValuesSuffix(selectedFlavors);
      model.buildConfigFields = _getBuildConfigFieldValues(selectedFlavors);

      return model;
    }
    return null;
  }

  List<String> _getFlavors() {
    List<String> flavorOptions = [
      'dev',
      'prod',
      'staging',
      'custom',
    ];
    List<String> defaultOption = List.from(flavorOptions)..removeLast();
    List<String> selectedFlavors = [];
    final response = process.getMultiSelectInput(
      prompt: 'What flavors do you want to create?',
      options: flavorOptions,
      defaultValue: defaultOption,
    );
    if (response.length == 1 && response.first == 3) {
      selectedFlavors = _getCustomFlavors();
    }
    if (response.length == 1) {
      e('Please select more than one flavor');
      return _getFlavors();
    }
    selectedFlavors = flavorOptions.getValuesAtIndexes<String>(response);
    // m('You chose flavor(s): $selectedFlavors');
    return selectedFlavors;
  }

  List<String> _getCustomFlavors() {
    final response = process.getInput(
      prompt: 'Add a custom flavor(s), (seperated by comma)',
    );
    final flavors = response.split(',');
    if (flavors.length == 1) {
      e('Please select more than one flavor');
      _getCustomFlavors();
    }
    return flavors;
  }

  Map<String, String>? _getFlavorAppName(List<String> selectedFlavors) {
    return inputParser(
      prompt: 'app_name',
      emptyError: 'Add app name',
      mixMatchError: 'App name mismatch',
      options: selectedFlavors,
      allowEmpty: true,
      validator: (p0) {
        if (p0.any((element) => element.isEmpty)) {
          throw ValidationError('app name cannot be empty');
        }
        return true;
      },
    );
  }

  Map<String, String> _getFlavorAppId(
      List<String> selectedFlavors, String package) {
    return inputParser(
      prompt: 'application id/bundle id',
      emptyError: 'Add id',
      mixMatchError: 'Id name mismatch',
      options: selectedFlavors,
      defaultValue: package,
      validator: (p0) {
        if (p0.length > 1 && p0.length != selectedFlavors.length ||
            p0.any((element) => element.isEmpty)) {
          throw ValidationError('Invalid application id');
        }
        return p0.every((packageName) =>
            AppValidators.isValidFlutterPackageName(packageName.trim()));
      },
    )!;
  }

  Future<Map<String, String>?> _getFlavorImage(
      List<String> selectedFlavors) async {
    Map<String, String> paths = {};
    final response = process.getConfirmation(
      prompt: 'Do you want app flavors icons?',
      defaultValue: false,
    );
    if (response) {
      for (var flavor in selectedFlavors) {
        final response = await _getFlavorImageByFlavor(
          flavor,
          paths.isNotEmpty ? paths.entries.last.value : null,
        );

        paths[flavor] = response;
      }

      return paths.entries.isNotEmpty ? paths : null;
    }
    return null;
  }

  Future<String> _getFlavorImageByFlavor(
    String flavor,
    String? lastPath,
  ) async {
    final response = process.getInput(
      prompt: ' Set app icon path for $flavor',
      defaultValue: lastPath,
      validator: (p0) => AppValidators.checkValidAppIconPath(p0.trim()),
    );
    if (!(await File(response).exists())) {
      e('file does not exist');
      return _getFlavorImageByFlavor(flavor, lastPath);
    } else {
      return response;
    }
  }

  Map<String, String>? _getFlavorVersionNameSuffix(
      List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want app flavors version name?',
      defaultValue: false,
    );
    if (response) {
      return inputParser(
        prompt: 'versionNameSuffix',
        emptyError: 'Add versionNameSuffix',
        mixMatchError: 'versionNameSuffix mismatch',
        options: selectedFlavors,
        allowEmpty: true,
        validator: (p0) {
          if (p0.isNotEmpty && p0.length != selectedFlavors.length ||
              p0.any((element) => element.isEmpty)) {
            throw ValidationError('Invalid version name suffix');
          }
          return true;
        },
      );
    }
    return null;
  }

  Map<String, String>? _getFlavorVersionCodeSuffix(
      List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want app flavors version code?',
      defaultValue: false,
    );
    if (response) {
      return inputParser(
        prompt: 'versionCode',
        emptyError: 'Add versionCode',
        mixMatchError: 'versionCode mismatch',
        options: selectedFlavors,
        allowEmpty: true,
        validator: (p0) {
          if (p0.isNotEmpty && p0.length != selectedFlavors.length ||
              p0.any((element) => element.isEmpty)) {
            throw ValidationError('Invalid version code suffix');
          }
          if (p0.any((element) => int.tryParse(element.trim()) == null)) {
            throw ValidationError('version code must be an integer');
          }
          return true;
        },
      );
    }
    return null;
  }

  Map<String, String>? _getFlavorMinSdkVersionSuffix(
      List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want app flavors min sdk version',
      defaultValue: false,
    );
    if (response) {
      return inputParser(
        prompt: 'android minSdkVersion',
        emptyError: 'Add android minSdkVersion',
        mixMatchError: 'minSdkVersion mismatch',
        options: selectedFlavors,
        allowEmpty: true,
        validator: (p0) {
          if (p0.isNotEmpty) {
            if (p0.length != selectedFlavors.length ||
                p0.any((element) => element.isEmpty)) {
              throw ValidationError('Invalid minSdkVersion');
            }
            if (p0.any((element) => int.tryParse(element.trim()) == null)) {
              throw ValidationError('minSdkVersion must be an integer');
            }
          }
          return true;
        },
      );
    }
    return null;
  }

  Map<String, String>? _getSigningConfig(List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want app flavors signing config?',
      defaultValue: false,
    );
    if (response) {
      Map<String, String> cofigs = {};
      for (var flavor in selectedFlavors) {
        final response = _getSigningConfigByFlavor(
          flavor,
          cofigs.isNotEmpty ? cofigs.entries.last.value : null,
        );

        cofigs[flavor] = "\"${response}\"";
        // cofigs[flavor] = response;
      }

      return cofigs.entries.isNotEmpty ? cofigs : null;
    }
    return null;
  }

  String _getSigningConfigByFlavor(
    String flavor,
    String? lastConfig,
  ) {
    final response = process.getInput(
      prompt: ' Set signingConfig for $flavor',
      defaultValue: lastConfig,
      // validator: (p0) {
      //   if (p0.isEmpty) {
      //     throw ValidationError('Invalid signing config');
      //   }
      //   return true;
      // },
    );

    return response;
  }

  List<CustomResValueModel>? _getResValuesSuffix(List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want to add resValues?',
      defaultValue: false,
    );
    if (response) {
      return _collectResValuesByFlavor(selectedFlavors);
    }
    return null;
  }

  List<CustomResValueModel> _collectResValuesByFlavor(
      List<String> selectedFlavors) {
    List<CustomResValueModel> customResValues = [];
    m("start entering res value for each flavor, type 'd' or 'done' to skip at any point");
    for (var flavor in selectedFlavors) {
      final resvalues = _collectResValues(flavor);
      customResValues.addAll(resvalues);
    }
    return customResValues;
  }

  List<CustomResValueModel> _collectResValues(String flavor) {
    List<CustomResValueModel> customResValues = [];

    while (true) {
      final response = process.getInput(
        prompt: '(seperated by comma) - '.grey() +
            'Enter variable_name, type, value, [target(debug, release, profile)] for ' +
            '($flavor)'.white().bold(),
      );
      if (response == 'd' || response == 'done') {
        return customResValues;
      }
      final resValues = response.split(',');
      if (resValues.length < 3) {
        e('Invalid input');
        return _collectResValues(flavor);
      } else if (resValues.length == 4) {
        if (resValues.last.trim() != 'debug' ||
            resValues.last.trim() != 'release' ||
            resValues.last.trim() != 'profile') {
          e('Invalid target');
          return _collectResValues(flavor);
        }
      } else {
        final model = CustomResValueModel(
          title: resValues.first,
          flavor: flavor,
          values: {
            'type': '${resValues[1]}',
            'value': '${resValues[2]}',
          },
        );

        if (resValues.length > 3) {
          model.values.addEntries([MapEntry('target', resValues[3])]);
        }
        customResValues.add(model);
      }
    }
  }

  List<CustomResValueModel>? _getBuildConfigFieldValues(
      List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Do you want to add build config fields?',
      defaultValue: false,
    );
    if (response) {
      return _collectBuildConfigFieldValuesByFlavor(selectedFlavors);
    }
    return null;
  }

  List<CustomResValueModel> _collectBuildConfigFieldValuesByFlavor(
      List<String> selectedFlavors) {
    List<CustomResValueModel> customResValues = [];
    m("start entering build config for each flavor, type 'd' or 'done' to skip at any point or skip a flavor");
    for (var flavor in selectedFlavors) {
      final resvalues = _collectBuildConfigFieldValues(flavor);
      customResValues.addAll(resvalues);
    }
    return customResValues;
  }

  List<CustomResValueModel> _collectBuildConfigFieldValues(String flavor) {
    List<CustomResValueModel> customResValueModel = [];
    while (true) {
      final response = process.getInput(
        prompt: '(seperated by comma) - '.grey() +
            'Enter field_name, type, value for ' +
            '($flavor)'.white().bold(),
      );

      if (response == 'd' || response == 'done') {
        return customResValueModel;
      }
      final resValues = response.split(',');
      if (resValues.length < 3) {
        e('Invalid input');
        return _collectBuildConfigFieldValues(flavor);
      } else {
        customResValueModel.add(
          CustomResValueModel(
            title: resValues.first,
            flavor: flavor,
            values: {
              'type': '${resValues[1]}',
              'value': '${resValues[2]}',
            },
          ),
        );
      }
    }
  }

  Map<String, String>? inputParser({
    required String prompt,
    required String emptyError,
    required String mixMatchError,
    required List<String> options,
    bool Function(List<String>)? validator,
    String? defaultValue,
    String? terminationPhase,
    bool allowEmpty = false,
  }) {
    final response = process.getInput(
      prompt: '(seperated by comma) - '.grey() +
          'Enter $prompt for ' +
          '(${options.spacedJoined})'.white().bold(),
      defaultValue: defaultValue,
      validator: (response) {
        if (response.isNotEmpty) {
          if (response == terminationPhase) return true;
          final responseParts = response.split(',');
          if (responseParts.length != options.length) {
            if (defaultValue == null) {
              throw ValidationError(mixMatchError);
            }
          }
          validator?.call(responseParts);
        } else {
          if (allowEmpty) return true;
          e(emptyError);
          throw ValidationError(emptyError);
        }

        return true;
      },
    );
    if (response.isNotEmpty) {
      if (response == terminationPhase) return null;
      final flavorName = response.split(',');
      Map<String, String> nameMap = {};

      for (var i = 0; i < options.length; i++) {
        String selected = options[i];
        if (defaultValue != null) {
          nameMap.addAll({'$selected': response.trim()});
        } else {
          nameMap.addAll({'$selected': flavorName[i].trim()});
        }
      }

      return nameMap;
    }
    return null;
  }
}
