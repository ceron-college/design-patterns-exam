package com.ceron.bridge;

import com.ceron.factory.EncryptionMessageFactory;
import com.ceron.implementation.EncryptionMessageInterface;

import java.io.InputStream;
import java.util.Properties;

/**
 * Main class to demonstrate the Bridge pattern with Factory design pattern.
 */
public class BridgePatternMain {

    public static void main(String[] args) {
        try {
            // Load properties from the configuration file
            Properties prop = new Properties();
            InputStream input = BridgePatternMain.class.getClassLoader()
                    .getResourceAsStream("config.properties");
            if (input == null) {
                throw new Exception("Unable to find config.properties");
            }
            prop.load(input);

            // Get the encryption class and password from the properties
            String encryptionClass = prop.getProperty("encryption.class");
            if (encryptionClass == null) {
                throw new Exception("encryption.class not specified in the config.properties file.");
            }

            String password = prop.getProperty("password");
            if (!encryptionClass.equals("com.ceron.encryption.NoEncryptionProcess") && password == null) {
                throw new Exception("password not specified in the config.properties file.");
            }

            final String message = "<Course><Name>Software Design Patterns</Name></Course>";

            // Get the encryption message interface from the factory
            EncryptionMessageInterface encryptionMessage = EncryptionMessageFactory.getEncryptionMessage();

            // Encrypt the message
            String encryptedMessage = encryptionMessage.EncryptMessage(message, password);
            System.out.println("Encrypted Message > " + encryptedMessage + "\n");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
