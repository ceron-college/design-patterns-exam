package com.ceron.implementation;

import com.ceron.encryption.EncryptInterface;

/**
 * Class that represents the bridge.
 */
public class EncryptionMessageBridge implements EncryptionMessageInterface {
    private EncryptInterface encryptionProcess;

    public EncryptionMessageBridge(EncryptInterface encryptionProcess) {
        this.encryptionProcess = encryptionProcess;
    }

    @Override
    public String EncryptMessage(String message, String password) throws Exception {
        return encryptionProcess.encrypt(message, password);
    }
}
