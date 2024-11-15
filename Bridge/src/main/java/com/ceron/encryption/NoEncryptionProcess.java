package com.ceron.encryption;

/**
 * Class that returns the message without any encryption.
 */
public class NoEncryptionProcess implements EncryptInterface {

    // Public no-argument constructor
    public NoEncryptionProcess() {
    }

    @Override
    public String encrypt(String message, String password) throws Exception {
        return message;
    }
}
