import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart';

//TODO: [WIP]auto enable authentication in forebase consile
class HttpProcess {
  final dio = Dio();

  void get(String url) async {
    final response = await dio.get(url);
    print(response.data);
  }

  void post(String url) async {
    final response = await dio.post(url);
    print(response.data);
  }

  void patchData(String url) async {
    final response = await patch(Uri.parse(url),
        body: jsonEncode({
          "signIn": {
            "email": {
              "enabled": true,
              "passwordRequired": true,
            }
          }
        }),
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'Content-Type': 'application/json',
          'Authorization':
              'SAPISIDHASH 1707003660_8ba63660a266ec6d30d93dfdb4a840c5cdc71c6f',
        });
    print(response.body);
    // final response = await dio.patch(url,
    //     data: {
    //       "signIn": {
    //         "email": {
    //           "enabled": true,
    //           "passwordRequired": true,
    //         }
    //       }
    //     },
    //     options: Options(
    //       contentType: 'application/json',
    //       headers: {
    //         'Accept': 'application/json, text/plain, */*',
    //         'Content-Type': 'application/json',
    //         'Authorization':
    //             'SAPISIDHASH 1707003660_8ba63660a266ec6d30d93dfdb4a840c5cdc71c6f',
    //       },
    //     ));
    // print(response.data);
    // getAuthorization();
  }

  getAuthorization() {
    final now = DateTime.now();
    final origin = "https://console.firebase.google.com";
    final timems =
        now.millisecondsSinceEpoch + (now.timeZoneOffset.inMinutes * 60 * 1000);
    final timesec = (timems / 1000).round();

    final SAPISID = "your_sapisid"; // Replace with your actual SAPISID

    final inputString = '$timesec $SAPISID $origin';
    final newHash = sha1.convert(utf8.encode(inputString)).toString();

    final SAPISIDHASH = '$timesec' + '_' + newHash;
    print('SAPISIDHASH: $SAPISIDHASH');
  }
}
