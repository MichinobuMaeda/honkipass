# 本気でパスワード

Sample: https://michinobu.jp/honkipass

## v4

- [Flutter](https://flutter.dev/) を利用

### Prerequisite

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Web
    - Chrome
- Mac OS
    - [Xcode](https://developer.apple.com/xcode/)
    - [CocoaPods](https://cocoapods.org/)
    - [create-dmg](https://github.com/create-dmg/create-dmg)
    - `brew install gnu-sed`
- Windows
    - [Windows install](https://flutter.dev/docs/get-started/install/windows): Windows setup
    - `start ms-settings:developers` --> enable Developer Mode
- Android
    - [Android Studio](https://developer.android.com/studio)
        - Menu: Tools > SDK Manage r> SDK Tools
            - Select 'Android SDK Command-line Tools'  
    - Emulator in Mac M1
        - [Initial Preview v3: Google APIs System Image](https://github.com/google/android-emulator-m1-preview/releases/tag/0.3)
    - Real device
        - USB Cable
        - [Configure on-device developer options](https://developer.android.com/studio/debug/dev-options)

```
$ flutter channel stable
$ flutter upgrade
```

### Local development envilonment

```
$ cd honkipass
$ flutter run -d chrome
$ flutter build web
```

### Create Project

#### Web app

https://flutter.dev/docs/get-started/web

```
$ flutter config --no-enable-android
$ flutter config --no-enable-ios
$ flutter create honkipass
```

#### Add Win32 Support

```
$ flutter config --enable-windows-desktop
$ flutter create --platforms=windows ./
$ start ms-settings:developers
 ---> enable Developer Mode
$ flutter run -d windows
$ flutter build windows
```

#### Add Mac OS Support

```
$ flutter config --enable-macos-desktop
$ flutter create --platforms=macos ./
$ flutter run -d macos
$ flutter build macos
```

#### Add Android Support

```
$ flutter config --enable-android
$ flutter create --platforms=android ./
$ flutter doctor -v
$ flutter doctor --android-licenses
```

Run the emurator or connect your device.

```
$ flutter devices
$ flutter run -d 'device name'
```

### Release

#### Web

```
$ flutter build web
$ rm -rf docs/web
$ cp -r build/web docs/
$ sed -i 's/<base\ href="\/">/<base\ href="\/honkipass\/web\/">/g' docs/web/index.html
```

#### Win32

```
PS> flutter build windows
PS> Remove-Item docs/windows/Honkipass.zip
PS> Remove-Item -Recurse build\windows\runner\Honkipass
PS> Rename-Item build\windows\runner\Release\ Honkipass
PS> Push-Location build\windows\runner
PS> Compress-Archive Honkipass ..\..\..\docs\windows\Honkipass.zip
PS> Pop-Location
```

#### Mac OS

```
$ flutter build macos
$ rm docs/macos/Honkipass.dmg
$ rm build/macos/Build/Products/Release/Honkipass.app
$ mv build/macos/Build/Products/Release/honkipass.app build/macos/Build/Products/Release/Honkipass.app
$ create-dmg docs/macos/Honkipass.dmg build/macos/Build/Products/Release/Honkipass.app
```
