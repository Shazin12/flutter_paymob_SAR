import 'package:dio/dio.dart';
import 'billing_data.dart';
import 'items.dart';

Future<Map> getAuthToken({required String apiKey}) async {
  try {
    var authToken = await Dio().post(
      _getAuthTokenUrl,
      data: {
        'api_key': apiKey,
      },
    );

    // log('authToken: ${authToken.data['token']}');
    return {'error': 'false', 'auth_token': authToken.data['token']};
  } on DioException catch (e) {
    return {
      'error': 'true',
      'message': e.message!.contains('connection error')
          ? "Unable to proceed, check your internet connection."
          : "Your API Key is not valid. Please check it and try again."
    };
  } catch (e) {
    return {
      'error': 'true',
      'message': "Unable to proceed, check your internet connection."
    };
  }
}

Future<Map> getOrderID({
  required String authToken,
  required num price,
  required String currency,
  List<Items>? items,
}) async {
  try {
    var orderID = await Dio().post(
      _getOrderIdUrl,
      data: {
        "auth_token": authToken,
        "delivery_needed": "false",
        "amount_cents": (price * 100).toString(),
        "currency": currency,
        "items": items?.map((e) => e.toJson()).toList() ?? [],
      },
    );
    // log('orderID: ${orderID.data['id']}');
    return {'error': 'false', 'id': orderID.data['id'].toString()};
  } on DioException catch (e) {
    return {
      'error': 'true',
      'message': "Payment Failed.",
      'data': e.response?.data,
    };
  } catch (e) {
    rethrow;
  }
}

Future<Map> getFinalToken(
    {required String orderID,
    required String authToken,
    required num price,
    required String integrationID,
    required String callbackUrl,
    required String currency,
    BillingData? billingData}) async {
  try {
    var finalToken = await Dio().post(_getFinalTokenUrl, data: {
      "auth_token": authToken,
      "amount_cents": (price * 100).toString(),
      "expiration": 3600,
      "currency": currency,
      "order_id": orderID,
      "integration_id": integrationID,
      "billing_data": billingData?.toJson() ?? BillingData().toJson(),
      "notification_url": callbackUrl,
    });
    //  log('finalToken: ${finalToken.data['token']}');
    return {
      'error': 'false',
      'token': finalToken.data['token'],
    };
  } on DioException catch (e) {
    return {
      'error': 'true',
      'message': "Payment Failed.",
      'data': e.response?.data,
    };
  } catch (e) {
    rethrow;
  }
}

Future<Map> getOrderInfo(
    {required String authToken, required String orderID}) async {
  try {
    var orderInfo = await Dio().post(
      _getOrderInfoUrl,
      data: {
        'auth_token': authToken,
        'order_id': orderID,
      },
    );
    return {'error': 'false', 'data': orderInfo.data};
  } on DioException catch (e) {
    return {
      'error': 'true',
      'message': "Information not found.",
      'data': e.response?.data,
    };
  } catch (e) {
    rethrow;
  }
}

const _getAuthTokenUrl = 'https://ksa.paymob.com/api/auth/tokens';
const _getOrderIdUrl = 'https://ksa.paymob.com/api/ecommerce/orders';
const _getFinalTokenUrl = 'https://ksa.paymob.com/api/acceptance/payment_keys';

const _getOrderInfoUrl =
    'https://ksa.paymob.com/api/ecommerce/orders/transaction_inquiry';
