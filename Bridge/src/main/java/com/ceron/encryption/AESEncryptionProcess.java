package com.ceron.encryption;

import java.security.Key;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 * Class that encrypts the message using the AES algorithm.
 */
public class AESEncryptionProcess implements EncryptInterface {

    // Public no-argument constructor
    public AESEncryptionProcess() {
    }

    @Override
    public String encrypt(String message, String password) throws Exception {
        Key key = new SecretKeySpec(password.getBytes(), "AES");
        Cipher c = Cipher.getInstance("AES");
        c.init(Cipher.ENCRYPT_MODE, key);
        byte[] encVal = c.doFinal(message.getBytes());
        Base64.Encoder encoder = Base64.getEncoder();
        String encodedString = encoder.encodeToString(encVal);
        return encodedString;
    }
}
