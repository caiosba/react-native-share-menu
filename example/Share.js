import React, {useEffect, useState} from 'react';
import {View, Text, Pressable, Image} from 'react-native';
import {ShareMenuReactView} from 'react-native-share-menu';

const Button = ({onPress, title, style}) => (
  <Pressable onPress={onPress}>
    <Text style={[{fontSize: 16, margin: 16}, style]}>{title}</Text>
  </Pressable>
)

const Share = () => {
  const [sharedData, setSharedData] = useState('');
  const [sharedMimeType, setSharedMimeType] = useState('');

  useEffect(() => {
    ShareMenuReactView.data().then(({mimeType, data}) => {
      setSharedData(data);
      setSharedMimeType(mimeType);
    });
  }, []);

  return (
    <View style={{flex: 1, backgroundColor: 'white'}}>
      <View style={{flexDirection: 'row', justifyContent: 'space-between'}}>
        <Button
          title="Dismiss"
          onPress={() => {
            ShareMenuReactView.dismissExtension();
          }}
          style={{color: 'red'}}
        />
        <Button
          title="Send"
          onPress={() => {
            ShareMenuReactView.dismissExtension();
          }}
          style={{color: 'blue'}}
        />
      </View>
      {sharedMimeType === 'text/plain' && <Text>{sharedData}</Text>}
      {sharedMimeType.startsWith('image/') && (
        <Image
          style={{width: '100%', height: 200}}
          resizeMode="contain"
          source={{uri: sharedData}}
        />
      )}
      <View style={{alignItems: 'center'}}>
        <Button
          title="Dismiss with Error"
          onPress={() => {
            ShareMenuReactView.dismissExtension('Dismissed with error');
          }}
          style={{color: 'red'}}
        />
        <Button
          title="Continue In App"
          onPress={() => {
            ShareMenuReactView.continueInApp();
          }}
        />
        <Button
          title="Continue In App With Extra Data"
          onPress={() => {
            ShareMenuReactView.continueInApp({hello: 'from the other side'});
          }}
        />
      </View>
    </View>
  );
};

export default Share;
