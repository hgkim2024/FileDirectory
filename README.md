## iOS 파일 시스템 특성
- iOS 파일 시스템은 SandBox 구조이다.
- SandBox는 Bundle Container, Data Container, iCloud Container 로 나누어져 있다.
- **iOS앱은 SandBox 외부에 파일을 생성하거나 접근 할 수 없다.**

<br>

<img width="50%" alt="fileSystem" src="https://github.com/hgkim2024/FileDirectory/assets/163487894/724465f3-64b2-42df-b901-481d6848466a">

<br>

- [Apple Developer] File System Programming Guide 링크
    + https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html
 
<br>

## 결론
- 파일을 단말에 저장 시 사진앱, Device Storage, App Storage 에 저장 할 수 있다.
- **사진앱에 저장된 파일은 사진앱이 아닌 앱에서 File Path로 접근할 수 없다.**
- 사진앱의 미디어 파일을 접근하려면 Photo Picker 를 통하여 접근 할 수 있다.
- **파일을 Device Storage 나 App Storage 저장하면 File Path 를 통해 앱에서 접근 가능하다.**
<br>

ex) Photo Picker 의 경우 파일을 가져올 때마다 파일 경로가 다르다.

```
Photo Picker 에서 같은 파일을 선택해도 선택할 때마다 가져오는 File Path 값이 다르다.
아래는 같은 파일을 선택 했을 때 가져온 File Path 값이다.
1. file:///private/var/mobile/Containers/Data/Application/AA77B5CD-E511-45D8-AC90-7FC78E4C61FD/tmp/.com.apple.Foundation.NSItemProvider.b6vhpO/IMG_0022.heic
2. file:///private/var/mobile/Containers/Data/Application/AA77B5CD-E511-45D8-AC90-7FC78E4C61FD/tmp/.com.apple.Foundation.NSItemProvider.AFG6DV/IMG_0022.heic
결론: 미디어 파일의 경우 안드로이드 처럼 File Path 로 접근할 수 없다.
```
