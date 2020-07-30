# API Docs

## ShareMenu

### `getInitialShare(callback: ShareCallback) : void`

#### Gets the shared item the app was opened with, if any.

#### Where `ShareCallback`

`(share: ShareData?) => void`

#### and `ShareData`

| Result    | Type   | Description                                                                               |
| --------- | ------ | ----------------------------------------------------------------------------------------- |
| mimeType  | String | The mime type of the shared data                                                          |
| data      | String | Either the shared text, or the location of the shared file                                |
| extraData | Object | Can be null. Any optional extra data your Share Extension React View opened the app with. |

### `addNewShareListener(callback: ShareCallback) : ShareListener`

#### Adds a listener for receiving shared data from other apps. Call `listener.remove()` to remove it on unmount.

#### Where `ShareCallback`

`(share: ShareData?) => void`

#### and `ShareData`

| Result    | Type   | Description                                                                               |
| --------- | ------ | ----------------------------------------------------------------------------------------- |
| mimeType  | String | The mime type of the shared data                                                          |
| data      | String | Either the shared text, or the location of the shared file                                |
| extraData | Object | Can be null. Any optional extra data your Share Extension React View opened the app with. |

#### and `ShareListener`

| Method   | Params | Description                              |
| -------- | ------ | ---------------------------------------- |
| remove() | None   | Removes a previously registered listener |

## ShareMenuReactView

### `dismissExtension(error?: String) : void`

#### Dismisses the open Share Extension. Send an error message as a parameter to notify the system that the share action was canceled.

### `openApp() : void`

#### Opens the App from the Share Extension.

### `continueInApp(extraData?: Object) : void`

#### Defers the handling of this share action to the main App. You can send any object as a parameter if you need more context to handle the share in-app.

### `data() : Promise<ShareData>`

#### Gets the shared data this Share Extension was opened with.

#### Where `ShareData`

| Result   | Type   | Description                                                |
| -------- | ------ | ---------------------------------------------------------- |
| mimeType | String | The mime type of the shared data                           |
| data     | String | Either the shared text, or the location of the shared file |
