## iOS 파일 시스템 특성
- iOS 파일 시스템은 SandBox 구조이다.
- 앱 SandBox는 Bundle Container, Data Container, iCloud Container 로 나누어져 있다.
- **앱은 일반적으로 Container 디렉토리 외부의 파일에 접근하거나 파일을 생성 할 수 없다.**

<br>

<img width="50%" alt="fileSystem" src="https://github.com/hgkim2024/FileDirectory/assets/163487894/724465f3-64b2-42df-b901-481d6848466a">

<br>

- **[[Apple Developer] File System Programming Guide 링크](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)**
 
<br>

## Bundle Container
- 앱에 데이터가 저장된 디렉토리이다.
- Write 할 수 없는 디렉토리이다.
- [리소스 프로그래밍 가이드](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i)를 통해 Read 권한을 얻을 수 있다.

<br>

## Data Container
- Documents, Documents/Inbox, Library, tem 디렉토리가 있다.

### Documents Directory
- 이 디렉토리에 파일을 저장하면 외부 앱에서 접근이 가능하다.
- iTunes 와 iCloud 에 백업된다.

### Documents/Inbox Directory
- 파일을 읽고 삭제할 수 있지만 새 파일을 만들거나 기존 파일에 Append 할 수 없다.
- 외부에서 앱에 접근될 때 사용하도록 권장된다.

### Library Directory
- 모든 파일의 최상위 디렉토리다.
- 일반적으로 [Application Support 와 Caches 하위 디렉토리](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1)로 사용된다.
- iTunes 와 iCloud 에 백업된다.

### tmp Directory
- 런타임에 일시적으로 사용할 파일을 저장하는 디렉토리이다.
- 앱이 종료되면 iOS 에서 강제로 제거 할 수도 있다.
- iTunes 와 iCloud 에 백업되지 않는다.

<br>

## iCloud Container
- TODO: - 추가

<br>

## File Manager
- iOS 파일시스템의 Data Container 에  CRUD 를 할 수 있게 도와주는 객체이다.

<br>

## Photo Picker
- 사진앱에 저장된 파일을 선택하여 파일 URL 을 받아온다.
- 파일 URL 을 통해 파일 데이터를 읽어 올 수 있다.
- 파일 URL 은 같은 파일을 선택해도 가져올 때마다 변한다.

```
아래는 같은 파일을 선택 했을 때 가져온 File Path 값이다.
1. file:///private/var/mobile/Containers/Data/Application/AA77B5CD-E511-45D8-AC90-7FC78E4C61FD/tmp/.com.apple.Foundation.NSItemProvider.**b6vhpO**/IMG_0022.heic
2. file:///private/var/mobile/Containers/Data/Application/AA77B5CD-E511-45D8-AC90-7FC78E4C61FD/tmp/.com.apple.Foundation.NSItemProvider.**AFG6DV**/IMG_0022.heic
```

<br>

## Document Picker
- Document 디렉토리의 접근 권한이 허용된 앱들의 Document 디렉토리에 파일을 선택하여 URL 을 받아온다.
- FileManager 에서 파일 URL 로 접근하여 CRUD 할 수 있다.

<br>

## Share
- Share 가 허용된 앱에 Swift 에서 지원되는 Data Type 을 전달한다.

<br>

## Blog Link
- https://www.notion.so/File-System-40de6d43d343413590f3c742c7808289?pvs=4
