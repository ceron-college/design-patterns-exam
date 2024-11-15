package com.ceron.encryption;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.util.Base64;

/**
 * Class that encrypts the message using the Blowfish algorithm.
 */
public class BlowfishEncryptionProcess implements EncryptInterface {

    // Public no-argument constructor
    public BlowfishEncryptionProcess() {
    }

    @Override
    public String encrypt(String message, String password) throws Exception {
        Key key = new SecretKeySpec(password.getBytes(), "Blowfish");
        Cipher c = Cipher.getInstance("Blowfish");
        c.init(Cipher.ENCRYPT_MODE, key);
        byte[] encVal = c.doFinal(message.getBytes());
        Base64.Encoder encoder = Base64.getEncoder();
        String encodedString = encoder.encodeToString(encVal);
        return encodedString;
    }
}
