package com.yenepay.yenepayflutter

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.lifecycle.*
import com.yenepay.yenepayflutter.Messages.YenePayApi
import com.yenepaySDK.PaymentOrderManager
import com.yenepaySDK.PaymentResponse
import com.yenepaySDK.model.YenePayConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** YenepayflutterPlugin */
class YenepayflutterPlugin: FlutterPlugin, Messages.YenePayApi, ActivityAware, LifecycleObserver {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var methodChannel : MethodChannel? = null
  private lateinit var eventChannel: EventChannel
  private var eventSender = MutableLiveData<EventChannel.EventSink>()
  private var activityBinding: ActivityPluginBinding? = null
  private val _paymentResponse = MutableLiveData<PaymentResponse>()
  val paymentResponse: LiveData<PaymentResponse>
    get() {
      return Transformations.switchMap(eventSender) { event ->
        if(event != null){
          _paymentResponse
        } else MutableLiveData()
      }
    }
  private val broadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
      if(intent?.action == PAYMENT_BROADCAST_ACTION) {
        processIntent(intent)
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.yenepay.yenepayflutter/response")
    eventChannel.setStreamHandler(eventHandler)
    methodChannel = YenePayApiHelper.setup(flutterPluginBinding.binaryMessenger, this)
    flutterPluginBinding.applicationContext.registerReceiver(broadcastReceiver, IntentFilter(PAYMENT_BROADCAST_ACTION))
    val completionIntent = PendingIntent.getActivity(flutterPluginBinding.applicationContext,
            PaymentOrderManager.YENEPAY_CHECKOUT_REQ_CODE,
            getIntentToOpenMainActivity(flutterPluginBinding.applicationContext), 0)
    val cancelationIntent = PendingIntent.getActivity(flutterPluginBinding.applicationContext,
            PaymentOrderManager.YENEPAY_CHECKOUT_REQ_CODE,
            getIntentToOpenMainActivity(flutterPluginBinding.applicationContext), 0)
    YenePayConfiguration.setDefaultInstance(YenePayConfiguration.Builder(flutterPluginBinding.applicationContext)
            .setGlobalCompletionIntent(completionIntent)
            .setGlobalCancelIntent(cancelationIntent)
            .build())
  }
  private val eventHandler = object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      eventSender.value = events
    }
    override fun onCancel(arguments: Any?) {
      eventSender.value = null
    }
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_START)
  fun onActivityStart(lifecycleOwner: LifecycleOwner){
    paymentResponse.observe(lifecycleOwner, Observer { payment ->
      payment?.let {
        eventSender.value?.success(it.toWritableMap())
      }
    })
  }
  private fun processIntent(intent: Intent?): Boolean{
    intent?.let {
      PaymentOrderManager.parseResponse(it)?.let { response ->
        resolvePromise(response)
        return true
      }
    }
    return false
  }
  private fun sendEvent(eventName: String,
                        params: HashMap<*,*>?) {
    Handler(Looper.getMainLooper()).post {
      // Call the desired channel message here.
      methodChannel?.invokeMethod(eventName, params)
    }

  }
  private fun resolvePromise(response: PaymentResponse) {
    _paymentResponse.value = response
  }
  private fun rejectPromise(message: String?) {
//    sendEvent(PAYMENT_ERROR_EVENT,
//            HashMap<String, String>().apply {
//              put("code", "Payment Error")
//              put("message",  message?: "User cancelled payment or some error occurred during payment")
//            })
    eventSender.value?.error("Payment Error", message?: "User cancelled payment or some error occurred during payment", null)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    tearDown()
  }

  override fun onDetachedFromActivity() {
    tearDownActivity()
  }

  override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
    onAttachedToActivity(activityPluginBinding)
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    setUpActivity(activityPluginBinding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    tearDownActivity()
  }

  override fun requestPayment(arg: HashMap<String, *>?) {
    arg.generatePaymentManager()?.let  { order ->
      startPaymentActivity(order)
    }?: throw Exception("Invalid Payment Request - data is null or invalid")
  }

  private fun startPaymentActivity(order: PaymentOrderManager){
    activityBinding?.activity?.startActivityForResult(
            NativePaymentActivity.createIntent(activityBinding?.activity!!, order),
            PAYMENT_REQ_CODE
    ) ?: throw Exception("Current activity is null")
  }
  private val activityResultListener = PluginRegistry.ActivityResultListener { requestCode, resultCode, data ->
    if (requestCode == PAYMENT_REQ_CODE) {
      if (resultCode == Activity.RESULT_CANCELED) {
        rejectPromise(NativePaymentActivity.extractErrorMessage(data))
      } else if (resultCode == Activity.RESULT_OK) {
        NativePaymentActivity.extractPaymentResponse(data)?.let {
          resolvePromise(it)
        }?: rejectPromise("Invalid Payment Response Data")
      }
      true
    } else false
  }
  private val newIntentListener = PluginRegistry.NewIntentListener { intent ->
    processIntent(intent)
  }
  private fun tearDown(){
    tearDownChannel()
    tearDownActivity()
  }

  private fun tearDownActivity() {
    activityBinding?.apply {
      removeActivityResultListener(activityResultListener)
      removeOnNewIntentListener(newIntentListener)
      val lifecycle: Lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(this)
      lifecycle.removeObserver(this@YenepayflutterPlugin)
    }
    activityBinding = null
  }

  private fun tearDownChannel() {
    methodChannel?.setMethodCallHandler(null)
    methodChannel = null
    eventChannel.setStreamHandler(null)
  }

  private fun setUpActivity(activityPluginBinding: ActivityPluginBinding) {
    val lifecycle: Lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityPluginBinding)
    lifecycle.addObserver(this)
    activityPluginBinding.apply {
      addActivityResultListener(activityResultListener)
      addOnNewIntentListener(newIntentListener)
      if(activity.intent?.dataString?.contains(":/payment2return", true) == true){
        processIntent(activity.intent)
      }
    }
    activityBinding = activityPluginBinding
  }
  private fun getIntentToOpenMainActivity(context: Context): Intent? {
    val packageName: String = context.packageName
    return context
            .packageManager
            .getLaunchIntentForPackage(packageName)
  }
}


object YenePayApiHelper {
  /** Sets up an instance of `YenePayApi` to handle messages through the `binaryMessenger`  */
  fun setup(binaryMessenger: BinaryMessenger?, api: YenePayApi?): MethodChannel {
    run {
      val channel = MethodChannel(binaryMessenger, "com.yenepay.yenepayflutter/request")
      if (api != null) {
        channel.setMethodCallHandler { message, reply ->
          when(message.method){
            "requestPayment" -> {
              val wrapped = HashMap<String, HashMap<*, *>?>()
              try {
//                @SuppressWarnings("ConstantConditions")
//                YenepayPaymentRequest input = YenepayPaymentRequest.fromMap((HashMap<?, ?>) message);
                api.requestPayment(message.arguments<HashMap<String, *>>())
                wrapped["result"] = null
                reply.success(wrapped)
              } catch (exception: Exception) {
                wrapped["error"] = Messages.wrapError(exception)
                reply.error("PaymentError", exception.message, exception.toString())
              }
            }
            else -> reply.notImplemented()
          }

        }
      } else {
        channel.setMethodCallHandler(null)
      }
      return channel
    }
  }
}

const val PAYMENT_REQ_CODE = 293
const val PAYMENT_RESPONSE_EVENT = "paymentResponseArrived"
const val PAYMENT_ERROR_EVENT = "paymentError"
const val PAYMENT_BROADCAST_ACTION = "com.yenepaysdkreactnative.broadcast.PAYMENT_RESPONSE_ACTION"
