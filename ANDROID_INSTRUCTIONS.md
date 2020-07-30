# Android Installation

<details>
<summary>Manual Install</summary>

- In `android/settings.gradle`

```gradle
...
include ':react-native-share-menu', ':app'
project(':react-native-share-menu').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-share-menu/android')
```

- In `android/app/build.gradle`

```gradle
...
dependencies {
    ...
    compile project(':react-native-share-menu')
}
```

- Register module (in MainApplication.java)

```java
import com.meedan.ShareMenuPackage;  // <--- import

public class MainApplication extends Application implements ReactApplication {
  ......
  @Override
  protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
      new MainReactPackage(),
      new ShareMenuPackage()  // <------ add here
    );
  }
  ......

}
```

</details>

## Add Intent Filter

- In `android/app/src/main/AndroidManifest.xml` in the `<activity>` tag:

```xml
<activity
  ...
  android:documentLaunchMode="never">
  ...
  <intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
    <data android:mimeType="image/*" />
    <!-- Any other mime types you want to support -->
  </intent-filter>
</activity>
```
