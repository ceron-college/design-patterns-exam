package com.ceron.implementation;

/**
 * Interface that defines the structure that bridge classes should have.
 */
public interface EncryptionMessageInterface {
    String EncryptMessage(String message, String password) throws Exception;
}
