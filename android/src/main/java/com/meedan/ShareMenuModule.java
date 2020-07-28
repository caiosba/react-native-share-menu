package com.meedan;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.widget.Toast;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.util.ArrayList;

public class ShareMenuModule extends ReactContextBaseJavaModule implements ActivityEventListener {

  final String NEW_SHARE_EVENT = "NewShareEvent";

  private ReactContext mReactContext;

  public ShareMenuModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mReactContext = reactContext;

    mReactContext.addActivityEventListener(this);
  }

  @NonNull
  @Override
  public String getName() {
    return "ShareMenu";
  }

  private String extractShared(Intent intent)  {
    String action = intent.getAction();
    String type = intent.getType();

    if (type == null) {
      return "";
    }

    if (Intent.ACTION_SEND.equals(action)) {
      if ("text/plain".equals(type)) {
        return intent.getStringExtra(Intent.EXTRA_TEXT);
      }

      if (type.startsWith("image/") || type.startsWith("video/")) {
        Uri imageUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
        if (imageUri != null) {
          return imageUri.toString();
        }
      } else {
        Toast.makeText(mReactContext, "Type is not supported", Toast.LENGTH_SHORT).show();
      }
    } else if (Intent.ACTION_SEND_MULTIPLE.equals(action)) {
      if (type.startsWith("image/") || type.startsWith("video/")) {
        ArrayList<Uri> imageUris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
        if (imageUris != null) {
          StringBuilder completeString = new StringBuilder();
          for (Uri uri : imageUris) {
            completeString.append(uri.toString()).append(",");
          }
          return completeString.toString();
        }
      } else {
        Toast.makeText(mReactContext, "Type is not support", Toast.LENGTH_SHORT).show();
      }
    }

    return "";
  }

  @ReactMethod
  public void getSharedText(Callback successCallback) {
    Activity currentActivity = getCurrentActivity();

    if (currentActivity == null) {
      successCallback.invoke("");
      return;
    }

    Intent intent = currentActivity.getIntent();

    String sharedText = extractShared(intent);
    successCallback.invoke(sharedText);
    clearSharedText();
  }

  private void dispatchEvent(String sharedText) {
    if (mReactContext == null || !mReactContext.hasActiveCatalystInstance()) {
      return;
    }

    mReactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(NEW_SHARE_EVENT, sharedText);
  }

  public void clearSharedText() {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }

    Intent intent = mActivity.getIntent();
    String type = intent.getType();

    if (type == null) {
      return;
    }

    if ("text/plain".equals(type)) {
      intent.removeExtra(Intent.EXTRA_TEXT);
      return;
    }

    if (type.startsWith("image/") || type.startsWith("video/")) {
      intent.removeExtra(Intent.EXTRA_STREAM);
    }
  }

  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    // DO nothing
  }

  @Override
  public void onNewIntent(Intent intent) {
    // Possibly received a new share while the app was already running

    Activity currentActivity = getCurrentActivity();

    if (currentActivity == null) {
      return;
    }

    String sharedText = extractShared(intent);
    dispatchEvent(sharedText);

    // Update intent in case the user calls `getSharedText` again
    currentActivity.setIntent(intent);
  }
}
