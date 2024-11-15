package com.ceron.encryption;

/**
 * Common interface for all encryption algorithm implementations.
 */
public interface EncryptInterface {
    String encrypt(String message, String password) throws Exception;
}
