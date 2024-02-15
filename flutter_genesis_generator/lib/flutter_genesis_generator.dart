library flutter_genesis_generator;

import 'package:build/build.dart';
import 'package:flutter_genesis_generator/src/app_builder.dart';
import 'package:flutter_genesis_generator/src/copy_builder.dart';

Builder copyBuilder(BuilderOptions options) => CopyBuilder();
Builder appCopierBuilder(BuilderOptions options) => AppCopierBuilder(options);
Builder appTestCopierBuilder(BuilderOptions options) =>
    AppTestCopierBuilder(options);
