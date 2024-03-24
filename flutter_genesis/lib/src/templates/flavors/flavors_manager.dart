// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/modules/generators/yaml/yaml_generator.dart';
import 'package:flutter_genesis/src/shared/extensions/lists.dart';
import 'package:flutter_genesis/src/shared/logger.dart';
import 'package:tint/tint.dart';

class FlavorModel {
  Map<String, String>? name;
  Map<String, String>? packageId;
  Map<String, String>? imagePaths;
  Map<String, String>? versionNameSuffix;
  Map<String, String>? versionCodeSuffix;
  Map<String, String>? minSdkVersion;
  List<CustomResValueModel>? resValues;
  List<CustomResValueModel>? buildConfigFields;
  final List<String> environmentOptions;
  FlavorModel({
    required this.environmentOptions,
    this.name,
    this.packageId,
    this.imagePaths,
    this.versionNameSuffix,
    this.versionCodeSuffix,
    this.minSdkVersion,
    this.resValues,
    this.buildConfigFields,
  });

  @override
  String toString() {
    return 'FlavorModel(name: $name, packageId: $packageId, imagePaths: $imagePaths, versionNameSuffix: $versionNameSuffix, versionCodeSuffix: $versionCodeSuffix, minSdkVersion: $minSdkVersion, resValues: $resValues, buildConfigFields: $buildConfigFields, environmentOptions: $environmentOptions)';
  }
}

class CustomResValueModel {
  final String title;
  final Map<String, String> values;
  CustomResValueModel({
    required this.title,
    required this.values,
  });

  Map<String, dynamic> toMap() {
    return {'${title}': values};
  }

  @override
  String toString() => 'CustomResValueModel(title: $title, values: $values)';
}

class FlavorManager {
  AdireCliProcess process = AdireCliProcess();
  YamlGenerator yamlGenerator = YamlGenerator();
  void createFlavor() {
    // _installDependencies();
    _getFlavorInfomation();
  }

  void _getFlavorInfomation() {
    final selectedFlavors = _getFlavors();
    m('You chose flavor(s): $selectedFlavors');
    FlavorModel model = FlavorModel(
      environmentOptions: selectedFlavors,
    );
    model.name = _getFlavorAppName(selectedFlavors);
    model.packageId = _getFlavorAppId(selectedFlavors);
    model.imagePaths = _getFlavorImage(selectedFlavors);
    model.versionNameSuffix = _getFlavorVersionNameSuffix(selectedFlavors);
    model.versionCodeSuffix = _getFlavorVersionCodeSuffix(selectedFlavors);
    model.minSdkVersion = _getFlavorMinSdkVersionSuffix(selectedFlavors);
    model.resValues = _getResValuesSuffix(selectedFlavors);
    model.buildConfigFields = _getBuildConfigFieldValues(selectedFlavors);

    m(' flavor(s) config: ${model.toString()}}');
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
      _getFlavorInfomation();
    }
    selectedFlavors = flavorOptions.getValuesAtIndexes<String>(response);
    // m('You chose flavor(s): $selectedFlavors');
    return selectedFlavors;
  }

  Map<String, String> _getFlavorAppName(List<String> selectedFlavors) {
    return inputParser(
      prompt: 'app_name',
      emptyError: 'Add flavor name',
      mixMatchError: 'Flavor name mismatch',
      options: selectedFlavors,
    )!;
  }

  Map<String, String> _getFlavorAppId(List<String> selectedFlavors) {
    return inputParser(
      prompt: 'package name/bundle id',
      emptyError: 'Add id',
      mixMatchError: 'Id name mismatch',
      options: selectedFlavors,
      defaultValue: 'com.example',
    )!;
  }

  Map<String, String>? _getFlavorVersionNameSuffix(
      List<String> selectedFlavors) {
    return inputParser(
      prompt: 'versionNameSuffix',
      emptyError: 'Add versionNameSuffix',
      mixMatchError: 'versionNameSuffix mismatch',
      options: selectedFlavors,
      allowEmpty: true,
    );
  }

  Map<String, String>? _getFlavorVersionCodeSuffix(
      List<String> selectedFlavors) {
    return inputParser(
      prompt: 'versionCode',
      emptyError: 'Add versionCode',
      mixMatchError: 'versionCode mismatch',
      options: selectedFlavors,
      allowEmpty: true,
    );
  }

  Map<String, String>? _getFlavorMinSdkVersionSuffix(
      List<String> selectedFlavors) {
    return inputParser(
      prompt: 'android minSdkVersion',
      emptyError: 'Add android minSdkVersion',
      mixMatchError: 'minSdkVersion mismatch',
      options: selectedFlavors,
      allowEmpty: true,
    );
  }

  List<CustomResValueModel>? _getResValuesSuffix(List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Add resValues?',
      defaultValue: true,
    );
    print(response);
    if (response) {
      return _collectResValues(selectedFlavors);
    }
    return null;
  }

  List<CustomResValueModel> _collectResValues(List<String> selectedFlavors) {
    List<CustomResValueModel> customResValues = [];
    while (true) {
      final response = process.getInput(
        prompt: '(seperated by comma) - '.grey() +
            'Enter resValues -  variable_name, type, value, [target(debug, release, profile)] for ' +
            '(${selectedFlavors.spacedJoined})'.white().bold(),
      );

      if (response == 'd' || response == 'done') {
        return customResValues;
        // break;
      }
      final resValues = response.split(',');
      if (resValues.length < 3) {
        e('Invalid input');
        return _collectResValues(selectedFlavors);
      } else {
        final model = CustomResValueModel(title: resValues.first, values: {
          'type': '${resValues[1]}',
          'value': '${resValues[2]}',
        });
        // final groupedMap = {
        //   '${resValues.first}': {
        //     'type': '${resValues[1]}',
        //     'value': '${resValues[2]}',
        //   }
        // };
        if (resValues.length > 3) {
          model.values.addEntries([MapEntry('target', resValues[3])]);
        }
        customResValues.add(model);
        // return model;
      }
    }
    // return null;
  }

  List<CustomResValueModel>? _getBuildConfigFieldValues(
      List<String> selectedFlavors) {
    final response = process.getConfirmation(
      prompt: 'Add build config fields' + '(Android only)'.grey() + '?',
      defaultValue: true,
    );
    print(response);
    if (response) {
      return _collectBuildConfigFieldValues(selectedFlavors);
    }
    return null;
  }

  List<CustomResValueModel> _collectBuildConfigFieldValues(
      List<String> selectedFlavors) {
    List<CustomResValueModel> customResValueModel = [];
    while (true) {
      final response = process.getInput(
        prompt: '(seperated by comma) - '.grey() +
            'Enter build config field -  field_name, type, value for ' +
            '(${selectedFlavors.spacedJoined})'.white().bold(),
      );

      if (response == 'd' || response == 'done') {
        return customResValueModel;
        // break;
      }
      final resValues = response.split(',');
      if (resValues.length < 3) {
        e('Invalid input');
        return _collectBuildConfigFieldValues(selectedFlavors);
      } else {
        // final groupedMap = {
        //   '${resValues.first}': {
        //     'type': '${resValues[1]}',
        //     'value': '${resValues[2]}',
        //   }
        // };
        customResValueModel.add(
          CustomResValueModel(
            title: resValues.first,
            values: {
              'type': '${resValues[1]}',
              'value': '${resValues[2]}',
            },
          ),
        );
      }
    }
    // return null;
  }

  Map<String, String>? _getFlavorImage(List<String> selectedFlavors) {
    Map<String, String> paths = {};
    for (var flavor in selectedFlavors) {
      final response = process.getInput(
        prompt: ' Set app icon path for $flavor',
        defaultValue: paths.isNotEmpty ? paths.entries.last.value : null,
      );
      paths[flavor] = response;
    }
    return paths.entries.isNotEmpty ? paths : null;
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

  Map<String, String>? inputParser({
    required String prompt,
    required String emptyError,
    required String mixMatchError,
    required List<String> options,
    String? defaultValue,
    String? terminationPhase,
    bool allowEmpty = false,
  }) {
    final response = process.getInput(
      prompt: '(seperated by comma) - '.grey() +
          'Set $prompt for ' +
          '(${options.spacedJoined})'.white().bold(),
      defaultValue: defaultValue,
      // validator: (response) {
      //TODO:  figure out why validator doesn't work
      //   // print('yassss');
      //   return false;
      //   if (response.isNotEmpty) {
      //     if (response == terminationPhase) return true;
      //     final flavorName = response.split(',');
      //     if (flavorName.length != options.length) {
      //       if (defaultValue == null) {
      //         e('$mixMatchError');
      //         return false;
      //       }
      //     }
      //   } else {
      //     if (allowEmpty) return true;
      //     e(emptyError);
      //     return false;
      //   }
      //   return true;
      // },
    );
    if (response.isNotEmpty) {
      if (response == terminationPhase) return null;
      final flavorName = response.split(',');
      Map<String, String> nameMap = {};
      if (flavorName.length != options.length) {
        if (defaultValue == null) {
          e('$mixMatchError');
          return inputParser(
            prompt: prompt,
            emptyError: emptyError,
            mixMatchError: mixMatchError,
            options: options,
            defaultValue: defaultValue,
          );
        }
      }
      for (var i = 0; i < options.length; i++) {
        String selected = options[i];
        if (defaultValue != null) {
          nameMap.addAll({'$selected': response});
        } else {
          nameMap.addAll({'$selected': flavorName[i]});
        }
      }

      return nameMap;
    } else {
      if (allowEmpty) return null;
      e(emptyError);
      return inputParser(
        prompt: prompt,
        emptyError: emptyError,
        mixMatchError: mixMatchError,
        options: options,
        defaultValue: defaultValue,
      );
    }
  }

  void _createYamlFile() {
    // yamlGenerator.generateFlavorizrConfig();
    // flavorizr.yaml
  }

  void _installDependencies() {
    _installRuby();
    _installXcodeproj();
  }

  Future<void> _installRuby() async {
    final result = await process.run(
      'ruby',
      arguments: ['-v'],
      showInlineResult: false,
      streamInput: false,
      catchErrorInline: false,
    );
    if (result!.exitCode != 0) {
      m('Ruby not installed, installing');
      process.run('brew', arguments: ['install', 'ruby']);
    } else {
      m('Ruby installed, skipping');
    }
  }

  Future<void> _installXcodeproj() async {
    final result = await process.run(
      'xcodeproj',
      arguments: ['--version'],
      showInlineResult: false,
      streamInput: false,
      catchErrorInline: false,
    );
    if (result!.exitCode != 0) {
      m('xcodeproj not installed, installing');
      process.run('gem', arguments: ['install', 'xcodeproj']);
    } else {
      m('xcodeproj installed, skipping');
    }
  }
}
