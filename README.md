# 本気でパスワード

## v4

- [Flutter](https://flutter.dev/) を利用

[v3](https://github.com/MichinobuMaeda/honkipass/tree/v3)

## Prerequisite

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Chrome
- For Mac OS
    - [Xcode](https://developer.apple.com/xcode/)
    - [CocoaPods](https://cocoapods.org/)


```
$ flutter channel stable
$ flutter upgrade
```

## Local development envilonment

```
$ cd honkipass
$ flutter run -d chrome
$ flutter build web
```

## Create Project

### Web app

https://flutter.dev/docs/get-started/web

```
$ flutter config --no-enable-android
$ flutter config --no-enable-ios
$ flutter create honkipass
```

### Add Mac OS Support

```
$ flutter config --enable-macos-desktop
$ flutter create --platforms=macos ./
$ flutter run -d macos
$ flutter build macos
```
