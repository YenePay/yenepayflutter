package com.yenepay.yenepayflutter

import com.yenepaySDK.PaymentOrderManager
import com.yenepaySDK.PaymentResponse
import com.yenepaySDK.model.OrderedItem
import java.util.ArrayList

fun HashMap<String, *>?.getString(key: String): String? {
  return this?.get(key) as String?
}
inline val HashMap<String, *>?.ipnUrl: String?
  get() = this?.getString("ipnUrl")
inline val HashMap<String, *>?.returnUrl: String?
  get() = this?.getString("returnUrl")
inline val HashMap<String, *>?.merchantCode: String?
  get() = this?.getString("merchantCode")
inline val HashMap<String, *>?.merchantOrderId: String?
  get() = this?.getString("merchantOrderId")
inline val HashMap<String, *>?.discount: Double
  get() = this.extractDouble("discount")
inline val HashMap<String, *>?.tax1: Double
  get() = this.extractDouble("tax1")
inline val HashMap<String, *>?.tax2: Double
  get() = this.extractDouble("tax2")
inline val HashMap<String, *>?.handlingFee: Double
  get() = this.extractDouble("handlingFee")
inline val HashMap<String, *>?.shippingFee: Double
  get() = this.extractDouble("shippingFee")
inline val HashMap<*, *>?.itemId: String?
  get() = if(this?.containsKey("itemId") == true) this["itemId"] as String else null
inline val HashMap<*, *>?.itemName: String?
  get() = if(this?.containsKey("itemName") == true) this["itemName"] as String else null
inline val HashMap<*, *>?.unitPrice: Double
  get() = this.extractDouble("unitPrice")
inline val HashMap<String, *>?.sandboxMode: Boolean
  get() = this.extractBoolean("isUseSandboxEnabled")
fun HashMap<String, *>?.extractItems(): MutableList<OrderedItem> {
  val result = mutableListOf<OrderedItem>()
  this?.let {
    if(it.containsKey("items") && it["items"] != null){
      val items = it["items"] as ArrayList<*>?
      items?.forEach { item ->
        if(item is HashMap<*,*>){
          result.add(OrderedItem(
            item.itemId, item.itemName, item.extractInt("quantity"), item.unitPrice
          ))
        }
      }
    }
  }
  return result
}


fun HashMap<*, *>?.extractDouble(key: String, defaultValue: Double = 0.0): Double {
  return this?.let {
    return if(it.containsKey(key) && it[key] is Double){
      it[key] as Double
    } else defaultValue
  }?: defaultValue
}
fun HashMap<*, *>?.extractInt(key: String, defaultValue: Int = 1 ): Int {
  return this?.let {
    return if(it.containsKey(key) && it[key] is Int){
      it[key] as Int
    } else defaultValue
  }?: defaultValue
}

fun HashMap<*, *>?.extractBoolean(key: String, defaultValue: Boolean = false ): Boolean {
  return this?.let {
    return if(it.containsKey(key) && it[key] != null){
      it[key] as Boolean
    } else defaultValue
  }?: defaultValue
}

fun HashMap<String, *>?.generatePaymentManager(): PaymentOrderManager? {
  if(this == null){
    return null
  }
  return PaymentOrderManager(merchantCode, merchantOrderId).also {
    it.discount = discount
    it.handlingFee = handlingFee
    it.ipnUrl = ipnUrl
    it.returnUrl = returnUrl
    it.shippingFee = shippingFee
    it.tax1 = tax1
    it.tax2 = tax2
    it.paymentProcess = "Cart"
    it.isUseSandboxEnabled = sandboxMode
    it.addItems(extractItems())
  }
}

fun PaymentResponse.toWritableMap(): HashMap<String, Any?> {
  return HashMap<String, Any?>().also {
    it["buyerId"] = buyerId
    it["customerCode"] = customerCode
    it["customerEmail"] = customerEmail
    it["customerName"] = customerName
    it["invoiceId"] = invoiceId
    it["invoiceUrl"] = invoiceUrl
    it["merchantCode"] = merchantCode
    it["merchantId"] = merchantId
    it["merchantOrderId"] = merchantOrderId
    it["orderCode"] = orderCode
    it["paymentOrderId"] = paymentOrderId
    it["signature"] = signature
    it["statusDescription"] = statusDescription
    it["status"] = status
    it["statusText"] = statusText
    it["verificationString"] = verificationString
    it["discount"] = discount
    it["grandTotal"] = grandTotal

    it["handlingFee"] = handlingFee
    it["itemsTotal"] = itemsTotal
    it["merchantCommisionFee"] = merchantCommisionFee
    it["shippingFee"] = shippingFee
    it["tax1"] = tax1
    it["tax2"] = tax2
    it["transactionFee"] = transactionFee

    it["isCanceled"] = isCanceled
    it["isDelivered"] = isDelivered
    it["isExpired"] = isExpiered
    it["isPaymentCompleted"] = isPaymentCompleted
    it["isPending"] = isPending
    it["isVerifying"] = isVerifying
    it["hasOpenDispute"] = hasOpenDipute()
  }
}
