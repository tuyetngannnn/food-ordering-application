package com.example.demo_firebase

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.listeners.PayOrderListener

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ZaloPaySDK.init(2554, Environment.SANDBOX);
    }

    override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    Log.d("newIntent", intent.toString())
    
    // Let ZaloPay SDK process the intent
    ZaloPaySDK.getInstance().onResult(intent)
    
    // Check for payment data
    val data = intent.data
    Log.d("newIntent", "Intent data: ${intent.data}")

    if (data != null && "demozpdk" == data.scheme && "app" == data.host) {
        val result = data.getQueryParameter("status") ?: "unknown"
        Log.d("PaymentResult", "Status: $result")

        Handler(Looper.getMainLooper()).post {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "channelPayOrder")
                .invokeMethod("paymentResult", result)
        }
    }
}

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channelPayOrder = "channelPayOrder"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelPayOrder)
            .setMethodCallHandler { call, result ->
                if (call.method == "payOrder"){
                    val tagSuccess = "[OnPaymentSucceeded]"
                    val tagError = "[onPaymentError]"
                    val tagCanel = "[onPaymentCancel]"
                    val token = call.argument<String>("zptoken")
                        ZaloPaySDK.getInstance().payOrder(this@MainActivity, token !!, "demozpdk://app",object: PayOrderListener {
                            override fun onPaymentCanceled(zpTransToken: String?, appTransID: String?) {
                                Log.d(tagCanel, String.format("[TransactionId]: %s, [appTransID]: %s", zpTransToken, appTransID))
                                result.success("User Canceled")
                            }

                            override fun onPaymentError(zaloPayErrorCode: ZaloPayError?, zpTransToken: String?, appTransID: String?) {
                                Log.d(tagError, String.format("[zaloPayErrorCode]: %s, [zpTransToken]: %s, [appTransID]: %s", zaloPayErrorCode.toString(), zpTransToken, appTransID))
                                result.success("Payment failed")
                            }

                            override fun onPaymentSucceeded(transactionId: String, transToken: String, appTransID: String?) {
                                Log.d(tagSuccess, String.format("[TransactionId]: %s, [TransToken]: %s, [appTransID]: %s", transactionId, transToken, appTransID))
                                result.success("Payment Success")
                            }
                        })
                } else {
                    Log.d("[METHOD CALLER] ", "Method Not Implemented")
                    result.success("Payment failed")
                }
            }
    }
}
