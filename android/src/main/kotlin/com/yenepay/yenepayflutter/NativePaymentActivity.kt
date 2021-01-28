package com.yenepay.yenepayflutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.yenepaySDK.PaymentOrderManager
import com.yenepaySDK.PaymentResponse
import com.yenepaySDK.YenePayPaymentActivity

class NativePaymentActivity: YenePayPaymentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    intent.paymentOrder?.let {
      val validationResult = it.validate()
      if(!validationResult.isValid){
        closeCancel("Validation Error - ${validationResult.errors.joinToString()}")
        return
      }
      startPayment(it)
    }?: closeCancel("Invalid payment data - payment is null")
  }
  private fun closeCancel(msg: String?) {
    val intent = Intent().apply {
      putExtra(PARAMS_PAYMENT_ERROR_MSG, msg?: "Payment error occurred")
    }
    setResult(Activity.RESULT_CANCELED, intent)
    finish()
  }
  private fun closeSuccess(response: PaymentResponse) {
    val intent = Intent().apply {
      putExtra(PARAMS_PAYMENT_RESPONSE, response)
    }
    setResult(Activity.RESULT_OK, intent)
    finish()
  }
  override fun onPaymentResponseArrived(response: PaymentResponse?) {
    response?.let {
      closeSuccess(it)
    }?: closeCancel("Invalid payment response - empty response")
  }

  override fun onPaymentResponseError(error: String?) {
    closeCancel(error)
  }

  companion object {
    fun createIntent(context: Context, payment: PaymentOrderManager): Intent {
      return Intent(context, NativePaymentActivity::class.java).apply {
        putExtra(ARGS_PAYMENT, payment)
      }
    }
    fun extractErrorMessage(intent: Intent?): String? {
      if(intent == null){
        return null;
      }
      return if(intent.hasExtra(PARAMS_PAYMENT_ERROR_MSG)) {
        intent.getStringExtra(PARAMS_PAYMENT_ERROR_MSG)
      } else null
    }
    fun extractPaymentResponse(intent: Intent?): PaymentResponse? {
      if(intent == null){
        return null;
      }
      return if(intent.hasExtra(PARAMS_PAYMENT_RESPONSE)) {
        intent.getSerializableExtra(PARAMS_PAYMENT_RESPONSE) as PaymentResponse?
      } else null
    }
  }
}

private const val ARGS_PAYMENT = "ARG_PARAM_PAYMENT"
private const val PARAMS_PAYMENT_ERROR_MSG = "YP_PARAMS_PAYMENT_ERROR_MSG"
private const val PARAMS_PAYMENT_RESPONSE = "YP_PARAMS_PAYMENT_RESPONSE"
private inline val Intent?.paymentOrder: PaymentOrderManager?
  get() = if(this?.hasExtra(ARGS_PAYMENT) == true) getSerializableExtra(ARGS_PAYMENT) as PaymentOrderManager? else null
