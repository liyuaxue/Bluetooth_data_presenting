# DERUXI - 启动与测试指南

项目路径：`e:\workspace2\modile-apps\bluetooth-data-presenting\bluetooth_data_presenting`

本指南说明如何在 Web、Windows 桌面、Android 真机与 Android 模拟器上启动与测试本项目，并包含 APK 打包与导入手机的步骤。

## 环境准备
- Flutter 已安装（推荐 `3.35.x`），使用 `flutter doctor` 检查环境。
- Android：安装 Android Studio 与 SDK/Platform Tools（ADB）。
- Windows 桌面：安装 Visual Studio（含“使用 C++ 的桌面开发”工作负载）。
- 浏览器：安装 Edge 或 Chrome（用于 Web 调试）。

## 快速查看设备
- 列出可用设备：`flutter devices`
- 显示详细信息：`flutter doctor -v`

## Web 调试
- 启动（调试模式）：
  - `flutter run -d web-server --web-hostname localhost --web-port 5173`
- 预览地址：`http://localhost:5173/`
- 热重载：在运行终端按 `r`（热重载）或 `R`（热重启），按 `q` 退出。
- 生产构建：`flutter build web`（生成到 `build/web`）。

## Windows 桌面
- 启动：`flutter run -d windows`
- 生产构建：`flutter build windows`

## Android 真机
1. 手机开启“开发者选项”和“USB 调试”。
2. 安装手机 USB 驱动（必要时）。
3. USB 连接手机，运行：`adb devices` 确认已连接（出现 `device` 状态）。
4. 启动：`flutter run -d android`
5. 如果提示无设备，运行 `flutter doctor -v` 排查 SDK/ADB 配置。

## Android 模拟器
1. 打开 Android Studio → AVD Manager。
2. 创建并启动一个模拟器（推荐 Pixel 机型，API 级别 33/34）。
3. 启动项目：`flutter run -d android`（或选择具体模拟器设备 ID）。

## Android APK 打包与安装

### 快速调试 APK（无需签名）
- 构建调试包：`flutter build apk --debug`
- 输出路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 安装到已连接手机：
  - `flutter install --debug`
  - 或 `adb install -r build/app/outputs/flutter-apk/app-debug.apk`

### 正式发布 APK（Release）
> 提示：Release 包需要签名；未签名的 `app-release.apk` 可能无法安装。

1. 生成签名密钥（Windows，PowerShell）：
   ```powershell
   keytool -genkeypair -v ^
     -keystore "$env:USERPROFILE\my-release-key.keystore" ^
     -alias upload ^
     -keyalg RSA ^
     -keysize 2048 ^
     -validity 10000
   ```
   - 记住设置的密码与 `alias`（上面示例为 `upload`）。

2. 在项目根创建 `key.properties`：
   ```properties
   storeFile=C:\Users\你的用户名\my-release-key.keystore
   storePassword=你的密码
   keyAlias=upload
   keyPassword=你的密码
   ```

3. 配置 `android/app/build.gradle.kts`（Kotlin DSL）：
   ```kotlin
   import java.util.Properties

   val keystoreProperties = Properties()
   val keystoreFile = rootProject.file("key.properties")
   if (keystoreFile.exists()) {
       keystoreProperties.load(keystoreFile.inputStream())
   }

   android {
       signingConfigs {
           create("release") {
               val storePath = keystoreProperties["storeFile"] as String?
               if (storePath != null) {
                   storeFile = file(storePath)
               }
               storePassword = keystoreProperties["storePassword"] as String?
               keyAlias = keystoreProperties["keyAlias"] as String?
               keyPassword = keystoreProperties["keyPassword"] as String?
           }
       }
       buildTypes {
           getByName("release") {
               signingConfig = signingConfigs.getByName("release")
               isMinifyEnabled = false
               isShrinkResources = false
           }
       }
   }
   ```

4. 构建 Release 包：
   - 单 APK：`flutter build apk --release`
   - 分 ABI：`flutter build apk --release --split-per-abi`
   - 输出路径：
     - 单 APK：`build/app/outputs/flutter-apk/app-release.apk`
     - 分 ABI：`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`、`app-armeabi-v7a-release.apk`、`app-x86_64-release.apk`

5. 安装到手机：
   - 单 APK：`adb install -r build/app/outputs/flutter-apk/app-release.apk`
   - 分 ABI：选择与手机架构匹配的 APK（多数真机为 `arm64-v8a`）：
     `adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

### 发布到商店（可选）
- 构建 AAB：`flutter build appbundle --release`
- 输出路径：`build/app/outputs/bundle/release/app-release.aab`
- 使用 Play Console 上传并完成签名与发布流程。

### 常见问题
- `INSTALL_PARSE_FAILED_NO_CERTIFICATES`：APK 未签名或签名不正确。使用调试包或正确配置 Release 签名。
- `INSTALL_FAILED_VERSION_DOWNGRADE`：设备已安装更高版本。卸载旧包或提升 `versionCode`。
- 设备显示 `unauthorized`：手机确认 USB 调试授权；执行 `adb kill-server && adb start-server` 后重插设备。
- 非 ADB 安装：将 APK 拷贝到手机并从文件管理器打开，需在系统设置中允许“安装未知来源”。

## 常用命令
- 查看日志：`flutter logs`
- 清理构建缓存：`flutter clean`
- 升级依赖：`flutter pub get`

## iOS 打包方式
- 环境要求：
  - macOS（Windows/Linux 无法构建 iOS 包）
  - Xcode（建议 15+）与命令行工具
  - CocoaPods：`sudo gem install cocoapods`
  - Apple Developer 账号（证书与描述文件）

- 项目配置与对齐：
  - 打开 `ios/Runner.xcworkspace`（不要用 `.xcodeproj`）
  - 在 `Runner` → `Signing & Capabilities`：
    - 选择你的 `Team`
    - 设置 `Bundle Identifier`（如 `com.yourcompany.deruxi`）
    - 勾选 `Automatically manage signing` 以自动签名（建议）
  - 应用名与图标已与安卓对齐：
    - 显示名 `CFBundleDisplayName=DERUXI`（`ios/Runner/Info.plist:7-8`）
    - 启动画面背景为 `#1677FF`（`ios/Runner/Base.lproj/LaunchScreen.storyboard:19-26,34-36`）
    - 图标来源于 `assets/icon.png`，已生成到 `ios/Runner/Assets.xcassets/AppIcon.appiconset`

- 依赖准备：
  - `flutter pub get`
  - `cd ios && pod install`

- 使用 Xcode 打包（推荐）：
  1. 在 Xcode 选择 `Runner` Scheme，目标设备选 `Any iOS Device (arm64)`
  2. 菜单 `Product` → `Archive`，完成后在 Organizer 中选择 `Distribute App`
  3. 根据用途选择：`App Store Connect`（上架/TestFlight）、`Ad Hoc`（企业内分发）、或 `Development`
  4. 选择签名方式，导出 `.ipa`

- 使用命令行打包 IPA：
  - 直接构建（需签名配置已在 Xcode 设置好）：
    - `flutter build ipa --release`
  - 指定导出选项（可选）：
    - 准备 `exportOptions.plist`（示例，App Store）：
      ```xml
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
        <key>method</key><string>app-store</string>
        <key>uploadBitcode</key><false/>
        <key>uploadSymbols</key><true/>
      </dict></plist>
      ```
    - 执行：`flutter build ipa --release --export-options-plist=ios/exportOptions.plist`
  - 输出：`build/ios/ipa/Runner.ipa`

- 本地真机安装（Ad Hoc/Development）：
  - 通过 Finder 或 Apple Configurator 2 将 `.ipa` 安装到连接的 iPhone
  - 或使用 Xcode Devices & Simulators 面板拖拽安装

- 版本号与构建号：
  - 在 `pubspec.yaml` 设置 `version: x.y.z+build`；Flutter 会同步到 iOS 的 `CFBundleShortVersionString` 与 `CFBundleVersion`

- 常见问题排查：
  - `Code signing is required`：检查 Team/BundleId 与证书/描述文件是否匹配；可先开启自动签名
  - `No profiles for 'xxx' were found`：在 Apple Developer 创建或用 Xcode 自动生成描述文件
  - Pod 相关错误：`cd ios && pod repo update && pod install`；若仍失败尝试 `flutter clean`
  - 构建缺少资源：确认 `flutter_launcher_icons` 已生成 iOS 图标，且 `Assets.xcassets` 正常引用

## 蓝牙测试提示（后续接入）
- Android 需在 `AndroidManifest.xml` 添加蓝牙权限；Windows 需启用系统蓝牙能力。
- 连接设备并订阅通知后，将数据报文传入 `lib/main.dart` 中的 `parseBluetoothPacket(...)`，映射到 `Telemetry` 即可驱动 UI 刷新。
- Web 端可用 Web Bluetooth（受浏览器与 HTTPS 限制）。

## 目录结构（关键部分）
- `lib/main.dart`：UI 布局与数据模型（Telemetry/DataController）。
- `web/`：Web 入口与静态资源。
- `android/`、`windows/`：平台工程文件。

如需我为你补充蓝牙依赖与权限配置，或按设备协议实现解析，请提供具体协议字段（长度、字节序、单位等）。
