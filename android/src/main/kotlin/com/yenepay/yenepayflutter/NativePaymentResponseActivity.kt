package com.yenepay.yenepayflutter

import android.content.Intent
import com.yenepaySDK.PaymentResponse
import com.yenepaySDK.YenePayPaymentActivity
import com.yenepaySDK.handlers.PaymentHandlerActivity

class NativePaymentResponseActivity: YenePayPaymentActivity() {
  override fun onPaymentResponseArrived(response: PaymentResponse?) {
    super.onPaymentResponseArrived(response)
    response?.let {
      val intent = Intent().apply {
        action = PAYMENT_BROADCAST_ACTION
        putExtra(PaymentHandlerActivity.KEY_PAYMENT_RESPONSE, it)
      }
      applicationContext.sendBroadcast(intent)
    }
    finish()
  }

  override fun onPaymentResponseError(error: String?) {
    super.onPaymentResponseError(error)
    finish()
  }
}
