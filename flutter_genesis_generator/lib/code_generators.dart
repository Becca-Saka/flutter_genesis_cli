library code_generators;

import 'package:build/build.dart';
import 'package:code_generators/src/app_builder.dart';
import 'package:code_generators/src/copy_builder.dart';

Builder copyBuilder(BuilderOptions options) => CopyBuilder();
Builder appCopierBuilder(BuilderOptions options) => AppCopierBuilder(options);
