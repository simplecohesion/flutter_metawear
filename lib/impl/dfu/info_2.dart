// import 'dart:convert';

// import 'package:flutter_metawear/impl/Version.dart';


// class Info2 {
//   late final Map<String, dynamic> _root;
//   late final Version _apiVersion;

//   Info2(Map<String, dynamic> root, String apiVersionStr) {
//     _root = root;
//     _apiVersion = Version.parse(apiVersionStr);
//   }

//   Image verifyImage(
//     String hardware,
//     String model,
//     String build,
//     String version,
//     Map<String, dynamic> attrs,
//   ) {
//     final image = Image(
//       hardware,
//       model,
//       build,
//       version,
//       attrs['filename'],
//       attrs['required-bootloader'],
//       attrs['min-android-version'],
//     );
//     if (Version.parse(image.minSdkVersion).compareTo(_apiVersion) > 0) {
//       throw UnsupportedError(
//         "You must use Android SDK >= v'${image.minSdkVersion}' with firmware v'$_apiVersion'",
//       );
//     }

//     return image;
//   }

//   Image findFirmwareImage(
//     String hardware,
//     String model,
//     String build,
//     Image Function(Map<String, dynamic> versions) transform,
//   ) {
//     final models = _root[hardware];
//     final builds = models[model];
//     final versions = builds[build];

//     return transform(versions);
//   }

//   Image findFirmwareImageByName(
//     String hardware,
//     String model,
//     String build,
//     String version,
//   ) {
//     return findFirmwareImage(hardware, model, build, (versions) {
//       if (versions.containsKey(version)) {
//         return verifyImage(
//           hardware,
//           model,
//           build,
//           version,
//           versions[version],
//         );
//       }
//       throw IllegalFirmwareFile(
//         "Firmware v'$version' does not exist for this board",
//       );
//     });
//   }

//   Image findLatestFirmwareImage(
//     String hardware,
//     String model,
//     String build,
//   ) {
//     return findFirmwareImage(hardware, model, build, (versions) {
//       final keys = versions.keys.cast<String>();
//       final keyObjects = keys.map((key) => Version.parse(key)).toSet()
//         ..removeWhere((key) => key == Version.empty);

//       final it = keyObjects.toList()..sort().reversed.iterator;
//       if (it.moveNext()) {
//         final target = it.current.toString();
//         return verifyImage(
//           hardware,
//           model,
//           build,
//           target,
//           versions[target],
//         );
//       } else {
//         throw StateError("No information available for this board");
//       }
//     });
//   }

//   List<Image> findBootloaderImages(
//     String hardware,
//     String model,
//     String key,
//     String current,
//   ) {
//     final models = _root[hardware];
//     final builds = models[model];
//     final versions = builds['bootloader'];
//     final acc = <Image>[];

//     final keyVersion = Version.parse(key);
//     while (Version.parse(current).compareTo(keyVersion) > 0) {
//       acc.insert(
//         0,
//         verifyImage(
//           hardware,
//           model,
//           'bootloader',
//           current,
//           versions[current],
//         ),
//       );
//       current = acc[0].requiredBootloader!;
//     }
//     return acc;
//   }
// }

// class Image {
//   final String hardware;
//   final String model;
//   final String build;
//   final String version;
//   final String? filename;
//   final String? requiredBootloader;
//   final String? minSdkVersion;

//   Image(
//     this.hardware,
//     this.model,
//     this.build,
//     this.version,
//     this.filename,
//     this.requiredBootloader,
//     this.minSdkVersion,
//   );

 
