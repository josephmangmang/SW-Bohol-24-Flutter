# sw_bohol_24

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

![alt text](images/demo.gif)

 ![alt text](<images/Screenshot 2024-08-09 at 11.46.08 PM.png>) ![alt text](<images/Screenshot 2024-08-09 at 11.46.12 PM.png>) ![alt text](<images/Screenshot 2024-08-09 at 11.46.17 PM.png>) ![alt text](<images/Screenshot 2024-08-09 at 11.46.25 PM.png>) 

Generate Keystore:
`keytool -genkeypair -v -keystore app.keystore -alias swbohol -keyalg RSA -keysize 2048 -validity 10000`
* Update app/build.gradle with the keystore path and password
```groovy
    signingConfigs {
        release {
            storeFile file('app.keystore')
            storePassword 'swbohol'
            keyAlias 'swbohol'
            keyPassword 'swbohol'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
        debug {
            signingConfig signingConfigs.release
        }
    }
```
