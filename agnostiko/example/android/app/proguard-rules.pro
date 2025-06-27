#Newland
-keepnames class android.newland.os.** { *; }
-keep class android.newland.AnalogSerialManager { *; }
-keep class android.newland.BootProvider { *; }
-keep class android.newland.NlCashBoxManager { *; }
-keep class android.newland.SettingsManager { *; }
-keep class android.newland.scan.ScanUtil {*;}
-keep class android.newland.net.ethernet.NlEthernetManager { *; }
-keep class com.newland.nsdk.core.api.internal.emvl2.type.** { *; }
-keep class com.newland.nsdk.core.api.internal.emvl2.listener.EmvJNIListener { *; }
-keep class com.newland.nsdk.core.common.keymanager.ST_SEC_KCV_DATA { *; }
-keep class com.newland.nsdk.core.internal.cardreader.CardReaderResult  { *; }
-keep class com.newland.nsdk.core.internal.cardreader.MagResult { *; }
-keep class com.newland.nsdk.core.internal.card.contactless.JNIActivationResult { *; }
-keep class com.newland.nsdk.core.internal.jni.EmvL2Jni { *; }
-keep class com.newland.nsdk.core.internal.crypto.ST_SEC_ENCRYPTION_DATA { *; }
-keep class com.newland.nsdk.core.internal.crypto.ST_SEC_DUKPT_DERIVATE_DATA { *; }
-keep class com.newland.nsdk.core.internal.keymanager.ST_SEC_KEYIN_DATA { *; }
-keep class com.newland.nsdk.core.common.keymanager.ST_SEC_ASYM_KEYIN_DATA { *; }
-keep class com.newland.nsdk.core.internal.pinentry.ST_NAPI_RSA_KEY { *; }
-keep class com.newland.nsdk.core.internal.pinentry.SysEventCallBack { *; }
-keepnames class com.newland.sdk.emvl3.api.common.configuration.** { *; }
-keep class com.newland.sdk.emvl3.internal.util.EmvConfigUtils { *; }

#PAX
-keep class com.pax.dal.**  { *; }
-keep class com.pax.jemv.**  { *; }
-keep class com.pax.neptunelite.api.Nepcore  { *; }
-keep class com.pax.neptunelite.api.NeptuneLiteUser  { *; }

-printusage ./proguardusage.txt
