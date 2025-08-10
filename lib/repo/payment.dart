import 'package:demo_firebase/utils/utils.dart';
import 'package:demo_firebase/models/zalopay.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:sprintf/sprintf.dart';

import '../utils/endpoint.dart';

class ZaloPayConfig {
  static const String appId = "2554";
  static const String key1 = "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn";
  static const String key2 = "trMrHtvjo6myautxDUiAcYsVtaeQ8nhf";
  static const String appUser = "zalopaydemo";
  static int transIdDefault = 1;
}

Future<CreateOrderResponse?> createOrder(int price) async {
  var header = <String, String>{};
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var body = <String, String>{};
  body["app_id"] = ZaloPayConfig.appId;
  body["app_user"] = ZaloPayConfig.appUser;
  body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = price.toStringAsFixed(0);
  body["app_trans_id"] = Utils.getAppTransId();
  body["embed_data"] = "{}";
  body["item"] = "[]";
  body["bank_code"] = Utils.getBankCode();
  body["description"] = Utils.getDescription(body["app_trans_id"]!);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["app_id"],
    body["app_trans_id"],
    body["app_user"],
    body["amount"],
    body["app_time"],
    body["embed_data"],
    body["item"]
  ]);
  body["mac"] = Utils.getMacCreateOrder(dataGetMac);
  print("mac: ${body["mac"]}");
  http.Response response = await http.post(
    Uri.parse(Endpoints.createOrderUrl),
    headers: header,
    body: body,
  );
  print("respone: ${response}");
  print("body_request: $body");
  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  print("data_response: $data}");

  return CreateOrderResponse.fromJson(data);
}
