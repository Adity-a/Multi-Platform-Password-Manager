# Multi-Platform Password Manager for Android

![Platform](https://img.shields.io/badge/platform-Android-brightgreen)

A secure and easy-to-use password manager for multiple devices that keeps your digital life safe. Built with robust AES-256 encryption, biometric authentication, and secure backup options.

---

## 🌟 About The Project

This Multi-Platform Password Manager provides a secure vault for all your credentials, accessible only to you. It simplifies password management without compromising on security, offering a clean, intuitive interface and powerful features.

### Screenshots

| Create | Add Entry | Vault | Unlock | Settings |
| :---: | :---: | :---: | :---: | :---: |
| ![App Screenshot 1](https://github.com/Adity-a/Multi-Platform-Password-Manager/blob/main/Screenshots/create.jpg) | ![App Screenshot 2](https://github.com/Adity-a/Multi-Platform-Password-Manager/blob/main/Screenshots/add_entry.jpg) | ![App Screenshot 3](https://github.com/Adity-a/Multi-Platform-Password-Manager/blob/main/Screenshots/vault.jpg) | ![App Screenshot 4](https://github.com/Adity-a/Multi-Platform-Password-Manager/blob/main/Screenshots/unlock.jpg) | ![App Screenshot 5](https://github.com/Adity-a/Multi-Platform-Password-Manager/blob/main/Screenshots/settings.jpg) |

---

## ✨ Features

* **Strong Encryption:** All data is encrypted on-device using the **AES-256 standard**.
* **Multi-Layered Security:**
    * **Biometric Authentication:** Unlock your vault with your fingerprint or face.
    * **PIN Protection:** A reliable PIN as a primary or fallback login method.
* **Encrypted Backup & Restore:**
    * Generate secure, encrypted backup files of your vault.
    * Easily import your data from a backup file.
    * **Auto-Export** functionality to prevent accidental data loss.
* **Secure Credential Storage:** Store website logins, app passwords, secure notes, and more.
* **User-Friendly Interface:** A clean, intuitive design that makes managing passwords a breeze.

---

## 🔐 Security Model

Security is the core foundation of this application.

* **End-to-End Encryption:** Your data is encrypted with a master password-derived key using **AES-256**. It is only decrypted locally on your device when you successfully authenticate.
* **Zero Knowledge:** Your master password or PIN is never stored. We do not have access to your credentials.
* **Robust Key Derivation:** We use key derivation functions (like PBKDF2 or Argon2) to protect your master password against brute-force attacks.
* **Offline First:** By default, your data lives only on your device. You have full control over your encrypted backup files.

---

## 🚀 Getting Started

### Prerequisites

* Android Studio / VS Code
* An Android device or emulator running Android 6.0 (Marshmallow) or higher.
* Physical Device

### Installation

1.  Clone the repo
    ```sh
    git clone [https://github.com/Adity-a/Multi-Platform-Password-Manager.git](https://github.com/Adity-a/Multi-Platform-Password-Manager.git)
    ```
2.  Open the project in Android Studio/ VS Code.
3.  Build and run the application.

---

## 🛠️ Usage

1.  **Set Up Master PIN:** On first launch, create your master PIN to encrypt the vault.
2.  **For Devices Not Support Biometrics** The authentication will be pin.
3.  **Enable Biometrics:** Automatic enable biometric authentication.
4.  **Add a Password:** Tap the `+` button to add new credentials.
5.  **Backup/Restore:** Go to `Home -> Backup/Export` automatically when new password is added.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

Distributed under the AGPL-3.0 License. See `LICENSE.txt` for more information.

---

## 📧 Links

Project Link: [https://github.com/Adity-a/Multi-Platform-Password-Manager](https://github.com/Adity-a/Multi-Platform-Password-Manager.git)
