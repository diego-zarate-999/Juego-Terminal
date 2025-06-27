package com.apps2go.agnostiko

import android.Manifest
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat

import kotlinx.coroutines.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.apps2go.agnostiko.Implementation
import com.apps2go.agnostiko.common.IImplementation
import com.apps2go.agnostiko.common.utils.AgnostikoError
import com.apps2go.agnostiko.common.utils.AgnostikoException

const val LOG_TAG = "AgnostikoPlugin"

class AgnostikoPlugin: FlutterPlugin, ActivityAware, MethodCallHandler {
  private lateinit var channel : MethodChannel

  private lateinit var bluetoothChannel : MethodChannel
  private lateinit var cardMethodsChannel : MethodChannel
  private lateinit var cardEventsChannel : EventChannel
  private lateinit var cryptoChannel : MethodChannel
  private lateinit var deviceChannel : MethodChannel
  private lateinit var emvModuleChannel : MethodChannel
  private lateinit var emvTransactionChannel : MethodChannel
  private lateinit var emvEventsChannel : EventChannel
  private lateinit var mdbChannel : MethodChannel
  private lateinit var pinEntryEventsChannel : EventChannel
  private lateinit var printerChannel : MethodChannel
  private lateinit var scannerChannel : MethodChannel
  private lateinit var pinpadChannel : MethodChannel
  private lateinit var serialMethodsChannel : MethodChannel
  private lateinit var serialEventsChannel : EventChannel

  private lateinit var implementation : IImplementation

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko")
    channel.setMethodCallHandler(this)

    bluetoothChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Bluetooth")
    cardMethodsChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/CardMethods")
    cardEventsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "agnostiko/CardEvents")
    cryptoChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Crypto")
    deviceChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Device")
    emvModuleChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/EmvModule")
    emvTransactionChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/EmvTransaction")
    emvEventsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "agnostiko/EmvEvents")
    mdbChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/MDB")
    pinEntryEventsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "agnostiko/PinEntryEvents")
    printerChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Printer")
    scannerChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Scanner")
    pinpadChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/Pinpad")
    serialMethodsChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agnostiko/SerialPortMethods")
    serialEventsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "agnostiko/SerialPortEvents")

    implementation = Implementation(flutterPluginBinding)

    implementation.initDeviceModule()
    bluetoothChannel.setMethodCallHandler(implementation.bluetoothHandler)
    deviceChannel.setMethodCallHandler(implementation.device)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    implementation.activity = binding.activity
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    GlobalScope.launch {
      try {
        if (call.method == "initSDK") {
          implementation.initSDK(call, {
            cardMethodsChannel.setMethodCallHandler(implementation.cardReaderHandler)
            cardEventsChannel.setStreamHandler(implementation.cardReaderHandler)
            cryptoChannel.setMethodCallHandler(implementation.crypto)
            deviceChannel.setMethodCallHandler(implementation.device)
            emvModuleChannel.setMethodCallHandler(implementation.emvModule)
            emvTransactionChannel.setMethodCallHandler(implementation.emvTransactionHandler)
            emvEventsChannel.setStreamHandler(implementation.emvTransactionHandler)
            mdbChannel.setMethodCallHandler(implementation.mdb)
            pinEntryEventsChannel.setStreamHandler(implementation.pinEntryHandler)
            printerChannel.setMethodCallHandler(implementation.printer)
            scannerChannel.setMethodCallHandler(implementation.scanner)
            pinpadChannel.setMethodCallHandler(implementation.pinpad)
            serialMethodsChannel.setMethodCallHandler(implementation.serialPortHandler)
            serialEventsChannel.setStreamHandler(implementation.serialPortHandler)

            Handler(Looper.getMainLooper()).post {
              result.success(null)
            }
          })
        } else if (call.method == "connectPinpad") {
          implementation.connectPinpad()
          Handler(Looper.getMainLooper()).post {
            result.success(null)
          }
        } else if (call.method == "connectBluetoothPinpad") {
          val address = call.arguments as String
          implementation.connectBluetoothPinpad(address)
          Handler(Looper.getMainLooper()).post {
            result.success(null)
          }
        } else {
          Handler(Looper.getMainLooper()).post {
            result.notImplemented()
          }
        }
      } catch(e: AgnostikoException) {
        Handler(Looper.getMainLooper()).post {
          result.error(AgnostikoError.TAG, e.message, e.code)
        }
      } catch(e: Throwable) {
        Handler(Looper.getMainLooper()).post {
          result.error(e.javaClass.name, e.message, null)
        }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    bluetoothChannel.setMethodCallHandler(null)
    cardMethodsChannel.setMethodCallHandler(null)
    cardEventsChannel.setStreamHandler(null)
    cryptoChannel.setMethodCallHandler(null)
    deviceChannel.setMethodCallHandler(null)
    emvModuleChannel.setMethodCallHandler(null)
    emvTransactionChannel.setMethodCallHandler(null)
    emvEventsChannel.setStreamHandler(null)
    mdbChannel.setMethodCallHandler(null)
    pinEntryEventsChannel.setStreamHandler(null)
    printerChannel.setMethodCallHandler(null)
    scannerChannel.setMethodCallHandler(null)
    pinpadChannel.setMethodCallHandler(null)
    serialMethodsChannel.setMethodCallHandler(null)
    serialEventsChannel.setStreamHandler(null)
    implementation.moduleDestroy()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // the Activity your plugin was attached to was destroyed to change configuration.
    // This call will be followed by onReattachedToActivityForConfigChanges().
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    // your plugin is now attached to a new Activity after a configuration change.
    implementation.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    // your plugin is no longer associated with an Activity. Clean up references.
  }
}
