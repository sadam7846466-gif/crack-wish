package com.vlucky.vlucky_flutter

import android.Manifest
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.crackwish/contacts"
    private var pendingResult: MethodChannel.Result? = null
    private val CONTACTS_PERMISSION_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getContacts") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
                    pendingResult = result
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_CONTACTS), CONTACTS_PERMISSION_CODE)
                } else {
                    fetchContacts(result)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CONTACTS_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pendingResult?.let { fetchContacts(it) }
            } else {
                pendingResult?.error("PERMISSION_DENIED", "Rehber izni reddedildi", null)
            }
            pendingResult = null
        }
    }

    private fun fetchContacts(result: MethodChannel.Result) {
        Thread {
            try {
                val contactsList = mutableListOf<Map<String, Any>>()
                val resolver = contentResolver
                val cursor = resolver.query(
                    ContactsContract.Contacts.CONTENT_URI,
                    null, null, null, null
                )

                if (cursor != null && cursor.count > 0) {
                    while (cursor.moveToNext()) {
                        val idIndex = cursor.getColumnIndex(ContactsContract.Contacts._ID)
                        val nameIndex = cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
                        
                        if (idIndex < 0 || nameIndex < 0) continue
                        
                        val id = cursor.getString(idIndex)
                        val name = cursor.getString(nameIndex) ?: ""

                        // Telefon Numaralarını Al
                        val phones = mutableListOf<String>()
                        val hasPhoneNumberIndex = cursor.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER)
                        if (hasPhoneNumberIndex >= 0 && cursor.getInt(hasPhoneNumberIndex) > 0) {
                            val pCursor = resolver.query(
                                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                                null,
                                ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                                arrayOf(id),
                                null
                            )
                            pCursor?.let {
                                while (it.moveToNext()) {
                                    val phoneNoIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                                    if (phoneNoIndex >= 0) {
                                        phones.add(it.getString(phoneNoIndex))
                                    }
                                }
                                it.close()
                            }
                        }

                        // E-postaları Al
                        val emails = mutableListOf<String>()
                        val eCursor = resolver.query(
                            ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                            null,
                            ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                            arrayOf(id),
                            null
                        )
                        eCursor?.let {
                            while (it.moveToNext()) {
                                val emailIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA)
                                if (emailIndex >= 0) {
                                    emails.add(it.getString(emailIndex))
                                }
                            }
                            it.close()
                        }

                        // Eğer e-posta veya telefon varsa listeye ekle
                        if (emails.isNotEmpty() || phones.isNotEmpty()) {
                            val contactMap = mapOf(
                                "name" to name.trim(),
                                "emails" to emails,
                                "phones" to phones
                            )
                            contactsList.add(contactMap)
                        }
                    }
                    cursor.close()
                }

                runOnUiThread {
                    result.success(contactsList)
                }

            } catch (e: Exception) {
                runOnUiThread {
                    result.error("FETCH_ERROR", e.localizedMessage, null)
                }
            }
        }.start()
    }
}
