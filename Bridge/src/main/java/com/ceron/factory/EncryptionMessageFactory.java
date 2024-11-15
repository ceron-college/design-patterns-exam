package com.ceron.factory;

import com.ceron.encryption.EncryptInterface;
import com.ceron.implementation.EncryptionMessageBridge;
import com.ceron.implementation.EncryptionMessageInterface;

import java.io.InputStream;
import java.util.Properties;

/**
 * Factory class to create the EncryptionMessageInterface via configuration.
 */
public class EncryptionMessageFactory {

    public static EncryptionMessageInterface getEncryptionMessage() throws Exception {
        // Load properties from the configuration file
        Properties prop = new Properties();
        InputStream input = EncryptionMessageFactory.class.getClassLoader()
                .getResourceAsStream("config.properties");
        if (input == null) {
            throw new Exception("Unable to find config.properties");
        }
        prop.load(input);

        // Get the class name from the properties
        String className = prop.getProperty("encryption.class");
        if (className == null) {
            throw new Exception("encryption.class not specified in the config.properties file.");
        }

        // Use reflection to create an instance of the class
        Class<?> clazz = Class.forName(className);
        EncryptInterface encryptionProcess = (EncryptInterface) clazz.getDeclaredConstructor().newInstance();

        // Create the bridge
        EncryptionMessageInterface encryptionMessage = new EncryptionMessageBridge(encryptionProcess);

        return encryptionMessage;
    }
}
