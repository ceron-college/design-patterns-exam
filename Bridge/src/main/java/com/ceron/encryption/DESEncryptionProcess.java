package com.ceron.encryption;

import java.security.spec.KeySpec;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;

/**
 * Class that encrypts the message using the DES algorithm.
 */
public class DESEncryptionProcess implements EncryptInterface {

    // Public no-argument constructor
    public DESEncryptionProcess() {
    }

    @Override
    public String encrypt(String message, String password) throws Exception {
        // Ensure the password is exactly 8 bytes
        if (password == null || password.length() < 8) {
            throw new Exception("Password must be at least 8 characters for DES encryption.");
        }
        password = password.substring(0, 8); // Use first 8 characters

        KeySpec keySpec = new DESKeySpec(password.getBytes("UTF8"));
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
        SecretKey key = keyFactory.generateSecret(keySpec);

        byte[] clearText = message.getBytes("UTF8");
        Cipher cipher = Cipher.getInstance("DES");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        byte[] encVal = cipher.doFinal(clearText);

        Base64.Encoder encoder = Base64.getEncoder();
        String encodedString = encoder.encodeToString(encVal);
        return encodedString;
    }
}
