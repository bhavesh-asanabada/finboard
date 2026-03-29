# FinBoard 💰

Personal financial tracker with direct MongoDB connection — no backend server required.

## Features

- **Dashboard** — monthly income, expenses, net balance, pie chart breakdown
- **Companies** — manage employers with hourly / monthly pay rates
- **Time Tracking** — clock in/out with automatic earnings calculation
- **Transactions** — income & expense log with category filtering
- **Direct MongoDB** — connects to your Atlas cluster straight from the device
- **Secure** — credentials stored in iOS Keychain / Android EncryptedSharedPreferences

## Install

**Download the latest build directly on your phone — no app store needed:**

👉 **[bhavesh-asanabada.github.io/finboard](https://bhavesh-asanabada.github.io/finboard/)**

Or grab the APK / IPA from [Releases](https://github.com/bhavesh-asanabada/finboard/releases).

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.10+ |
| Database | MongoDB Atlas (via `mongo_dart`) |
| State | Provider |
| Charts | fl_chart |
| Secrets | flutter_secure_storage |

## Development

```bash
flutter pub get
flutter run
```

## Release

Push a version tag to trigger the CI/CD pipeline:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Or use the **Bump Version** workflow from the Actions tab.
