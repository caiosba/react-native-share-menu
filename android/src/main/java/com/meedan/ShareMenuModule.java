package com.meedan;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.meedan.ShareMenuPackage;

import java.util.Map;
import java.util.ArrayList;

import android.widget.Toast;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

public class ShareMenuModule extends ReactContextBaseJavaModule {

  private ReactContext mReactContext;

  public ShareMenuModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mReactContext = reactContext;
  }

  @Override
  public String getName() {
    return "ShareMenu";
  }

  protected void onNewIntent(Intent intent) {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }

    mActivity.setIntent(intent);
  }  

  @ReactMethod
  public void getSharedText(Callback successCallback) {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }
    
    Intent intent = mActivity.getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if ("text/plain".equals(type)) {
        String input = intent.getStringExtra(Intent.EXTRA_TEXT);
        successCallback.invoke(input);
      } else if (type.startsWith("image/") || type.startsWith("video/")) {
        Uri imageUri = (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
        if (imageUri != null) {
          successCallback.invoke(imageUri.toString());
        }
      } else {
        Toast.makeText(mReactContext, "Type is not support", Toast.LENGTH_SHORT).show();
      }
    } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
        if (type.startsWith("image/") || type.startsWith("video/")) {
          ArrayList<Uri> imageUris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
          if (imageUris != null) {
            String completeString = new String();
            for (Uri uri: imageUris) {
              completeString += uri.toString() + ",";
            }
            successCallback.invoke(completeString);
          }
        } else {
          Toast.makeText(mReactContext, "Type is not support", Toast.LENGTH_SHORT).show();
        }
    }
  }

  @ReactMethod
  public void clearSharedText() {
    Activity mActivity = getCurrentActivity();
    
    if(mActivity == null) { return; }

    Intent intent = mActivity.getIntent();
    String type = intent.getType();
    if ("text/plain".equals(type)) {
      intent.removeExtra(Intent.EXTRA_TEXT);
    } else if (type.startsWith("image/") || type.startsWith("video/")) {
      intent.removeExtra(Intent.EXTRA_STREAM);
    }
  }
}
