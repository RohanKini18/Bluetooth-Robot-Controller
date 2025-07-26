# 🤖 Bluetooth Robot Controller

A simple and interactive mobile application developed using **Flutter** that allows users to wirelessly control a robot using **Bluetooth** communication with an **Arduino + HC-05** module.

---

## 📱 App Features

- **Bluetooth Device Scanning**: Lists all paired Bluetooth devices.
- **Connect & Communicate**: Connect to Arduino’s HC-05 module.
- **Manual Control Panel**:
  - Forward (F)
  - Backward (B)
  - Left (L)
  - Right (R)
  - Auto-stops after short movement unless held.
- **Disconnect** option returns user to device selection screen.
- **User Feedback** with Snackbars after sending commands.
- Designed with a clean, responsive, and modern UI.

⚠️ Note: Requires location & Bluetooth permissions. App targets Android 10+.

---

## ⚙️ Technologies Used

- **Flutter (Dart)**
- `flutter_bluetooth_serial` for Bluetooth communication
- `permission_handler` for runtime permissions

---

## 🛠️ Arduino Setup

### Components Required:
- Arduino Uno
- HC-05 Bluetooth Module
- L298N Motor Driver
- 4 DC Motors (for robot movement)
- Power Supply (Battery pack)

### HC-05 Wiring:
| HC-05 Pin | Arduino Pin |
|-----------|-------------|
| VCC       | 5V          |
| GND       | GND         |
| TXD       | RX (D0)     |
| RXD       | TX (D1) (via Voltage Divider) |

> Use a voltage divider (e.g. 1kΩ + 2kΩ) between Arduino TX and HC-05 RX to avoid damaging the HC-05.

### Arduino Sketch (Sample):
```cpp
char command;

void setup() {
  Serial.begin(9600);
  pinMode(2, OUTPUT); // Left motor
  pinMode(3, OUTPUT); // Right motor
}

void loop() {
  if (Serial.available()) {
    command = Serial.read();

    switch (command) {
      case 'F': forward(); break;
      case 'B': backward(); break;
      case 'L': left(); break;
      case 'R': right(); break;
      case 'S': stopMotors(); break;
    }
  }
}

void forward() { digitalWrite(2, HIGH); digitalWrite(3, HIGH); }
void backward() { digitalWrite(2, LOW); digitalWrite(3, LOW); }
void left() { digitalWrite(2, LOW); digitalWrite(3, HIGH); }
void right() { digitalWrite(2, HIGH); digitalWrite(3, LOW); }
void stopMotors() { digitalWrite(2, LOW); digitalWrite(3, LOW); }

```

---

```💰 You can help me by Donating```

[![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/rohankini) [![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RohanKinirk) 


