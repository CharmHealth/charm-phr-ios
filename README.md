# Charm mPHR iOS

This document lists all external dependencies used in the Charm mPHR iOS project, including installation steps and important notes.

---

## Prerequisites

- **Xcode**: 26.x or later
- **CocoaPods**: Version 1.16.2 or later
- **iOS**: 15.0 or later
- **Minimum Deployment Target (Podfile)**: 13.0

---

## 0. Initial Project Setup

### Clone the Repository

```bash
git clone https://zrepository.zoho.com/medicalmine/charm/Mobile_Team/charm-phr-ios.git
cd charm-phr-ios/native/ChARM_PHR/
```

### Download Fonts

Download the **Fonts** folder from WorkDrive and place it parallel to the `.xcworkspace` file:

- **URL**: https://workdrive.zoho.com/folder/1zpgp64aa913f137447d288f3ff3dafa1c1ab

```
ChARM_PHR/
├── Fonts/              <-- Place here
├── PHR/
├── PHR.xcworkspace
└── ...
```

### Download Frameworks

1. Create a **Frameworks** folder parallel to the `.xcworkspace` file (if it doesn't exist):
   ```bash
   mkdir -p Frameworks
   ```

2. Download all frameworks from WorkDrive:
   - **URL**: https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331
   - Download `MobileRTC.xcframework`, `zoomcml.xcframework`, and `Razorpay.xcframework`

3. Download `MobileRTCResources.bundle` from the same WorkDrive link and place it inside `Frameworks/` alongside `MobileRTC.xcframework`

```
Frameworks/
├── MobileRTC.xcframework
├── MobileRTCResources.bundle
├── Razorpay.xcframework
└── zoomcml.xcframework
```

### Download Secrets File

The `mPHR-Secrets.plist` file contains OAuth client credentials required for authentication. This file is not committed to the repository. Download it from the vault (shared by your team lead) and place it at:

```
PHR/SupportingFiles/mPHR-Secrets.plist
```

> **Note:** If this file is missing, the app will fail to authenticate. Contact your team lead if you haven't received the vault access.

### Install Pods and Open

```bash
pod install
open PHR.xcworkspace
```

---

## 1. CocoaPods Dependencies

### Pod Sources

The project uses the following pod sources. These must be configured before running `pod install`:

| Source | URL |
|--------|-----|
| Charm Pod Specs (Private) | `https://zrepository.zoho.com/MedicalMine/charm/Mobile_Team/charm_pod_specs.git` |
| Zoho Apptics (GitHub) | `https://github.com/zoho/Apptics.git` |
| CocoaPods Official | `https://github.com/CocoaPods/Specs` |

### Installation

1. Ensure CocoaPods is installed:
   ```bash
   sudo gem install cocoapods
   ```

2. Navigate to the project directory:
   ```bash
   cd native/ChARM_PHR
   ```

3. Install pods:
   ```bash
   pod install
   ```

4. Always open the project using the workspace file:
   ```
   PHR.xcworkspace
   ```

### Pod List

| Pod | Version | Source | Purpose |
|-----|---------|--------|---------|
| **UICKeyChainStore** | 2.2.1 | CocoaPods | Secure keychain storage for credentials and tokens |
| **CharmCommonComponents** | 1.0 | Charm Pod Specs | Internal shared UI components and utilities |
| **MDTextField** | 1.1 | Charm Pod Specs | Material Design text fields (depends on CharmCommonComponents) |
| **ZohoAuth** | 1.5 | CocoaPods | Zoho authentication framework |
| **Apptics-Swift** | 3.3.2 | GitHub Apptics | Analytics, crash reporting, and diagnostics |
| **AppticsInAppUpdate** | 3.3.2 | GitHub Apptics | In-app update prompts for new versions |
| **AppticsRateUs** | 3.3.2 | GitHub Apptics | App store rating prompts |
| **JTAppleCalendar** | 8.0.5 | CocoaPods | Calendar UI component for appointment booking |

### Transitive Dependencies (auto-installed)

| Pod | Version | Pulled By |
|-----|---------|-----------|
| Apptics-SDK | 3.3.2 | Apptics-Swift |
| AppticsAnalytics | 3.3.2 | Apptics-Swift |

---

## 2. Vendored Frameworks (Manual)

These frameworks are not managed by CocoaPods. They are stored in the `Frameworks/` directory and must be manually updated.

> **First-time setup:** See [Section 0: Initial Project Setup](#0-initial-project-setup) to download all frameworks from WorkDrive. The steps below are for **updating** existing frameworks.

### 2.1 MobileRTC (Zoom Video SDK)

| Property | Value |
|----------|-------|
| **Framework** | `MobileRTC.xcframework` |
| **Resource Bundle** | `MobileRTCResources.bundle` |
| **Developer** | Zoom Video Communications, Inc. |
| **Purpose** | Video consultation / telehealth calls |
| **Download** | [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331) |
| **Used In** | `JoinZoomCallViewController`, `TelehealthUtil`, `AppointmentsViewController`, `ModalRelatedMacros` |

**Update Steps:**

1. Co-ordinate with the tele-health module owner and get the latest stable `MobileRTC.xcframework` and `MobileRTCResources.bundle`
2. Replace the existing files in `Frameworks/`:
   ```
   Frameworks/MobileRTC.xcframework
   Frameworks/MobileRTCResources.bundle
   ```
3. In Xcode, verify the framework is listed under:
   - **Target > General > Frameworks, Libraries, and Embedded Content** (set to "Embed & Sign")
   - **Build Phases > Embed Frameworks**
4. Clean build folder (`Cmd + Shift + K`) and rebuild
5. Upload the updated frameworks to [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331) so other developers can access them

> **IMPORTANT: MobileRTC must be updated every 3 months.** Zoom deprecates older SDK versions on a rolling basis. If the SDK is not updated within the deprecation window, video consultation will stop working in the app. Please co-ordinate with the tele-health module owner and get the latest stable framework once in 3 months and update the app.

### 2.2 zoomcml (Zoom Communications)

| Property | Value |
|----------|-------|
| **Framework** | `zoomcml.xcframework` |
| **Developer** | Zoom Communications, Inc. |
| **Purpose** | Supporting framework for Zoom SDK |
| **Download** | [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331) |

**Update:**
This framework is bundled alongside the Zoom SDK and must be updated together with `MobileRTC.xcframework`. Follow the same steps as 2.1.

### 2.3 Razorpay (Payment Gateway)

| Property | Value |
|----------|-------|
| **Framework** | `Razorpay.xcframework` |
| **Developer** | Razorpay Software Private Limited |
| **Purpose** | Payment processing for appointment booking and invoice payments |
| **Download** | [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331) or [Razorpay iOS SDK docs](https://razorpay.com/docs/payments/payment-gateway/ios-integration/) |
| **Used In** | `BookAppointmentViewController`, `AddAppointmentViewController`, `InvoiceViewController` |

**Update Steps:**

1. Download the latest `Razorpay.xcframework` from [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331) or from the [Razorpay iOS SDK documentation](https://razorpay.com/docs/payments/payment-gateway/ios-integration/)
2. Replace the existing file in `Frameworks/`:
   ```
   Frameworks/Razorpay.xcframework
   ```
3. In Xcode, verify the framework is listed under:
   - **Target > General > Frameworks, Libraries, and Embedded Content** (set to "Embed & Sign")
   - **Build Phases > Embed Frameworks**
4. Clean build folder (`Cmd + Shift + K`) and rebuild
5. If downloaded from Razorpay directly, upload the updated framework to [WorkDrive](https://workdrive.zoho.com/folder/1zpgpa6298bddedd740eabbd66252f5b3d331)

---

## 3. System Frameworks

These are Apple-provided frameworks linked in the project. No installation required.

| Framework | Purpose |
|-----------|---------|
| UIKit | Core UI components |
| Foundation | Base library |
| SwiftUI | Modern declarative UI |
| WebKit | Web views (login, compose message) |
| CoreData | Local data persistence (reminders, patient cache) |
| HealthKit | Wellness tracking and health data sync |
| PDFKit | PDF document viewing |
| QuickLook | Document preview |
| LocalAuthentication | Face ID / Touch ID for lock screen |
| PhotosUI | Photo picker for attachments |
| UniformTypeIdentifiers | File type identification |
| Security | Keychain and security services |
| CommonCrypto | Cryptographic functions |

---

## 4. Build Configuration

| Setting | Value |
|---------|-------|
| `use_frameworks!` | Enabled (dynamic frameworks) |
| `use_modular_headers!` | Enabled |
| Deployment Target | iOS 13.0 |
| Apptics Pre-build Script | Uploads dSYM for Release/Appstore configurations |
| Apptics Config File | `PHR/SupportingFiles/charm-apptics-config.plist` |

### Build Configurations

| Configuration | Purpose |
|---------------|---------|
| Debug | Local development |
| Release | Production builds |
| Development | Development environment |
| CustomBrandApp | White-label / custom branding |

---

## 5. Troubleshooting

### Pod Install Fails
- Ensure you have access to the private pod spec repositories
- Run `pod repo update` before `pod install`
- If source authentication fails, verify your Zoho repository credentials

### MobileRTC Build Errors
- Verify the `.xcframework` is properly embedded (not just linked)
- Ensure `MobileRTCResources.bundle` is included in **Build Phases > Copy Bundle Resources**
- Check that the framework version is not deprecated by Zoom

### Razorpay Build Errors
- Ensure the framework supports the current Xcode and Swift version
- Check that the framework is set to "Embed & Sign" (not "Do Not Embed")
