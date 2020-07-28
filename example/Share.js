import React, {useEffect, useState} from 'react';
import {View, Text, Pressable, Image} from 'react-native';
import {ShareMenuReactView} from 'react-native-share-menu';

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
      <Pressable
        onPress={() => {
          ShareMenuReactView.dismissExtension();
        }}
        style={{alignItems: 'flex-end'}}>
        <Text style={{fontSize: 16, margin: 16, color: 'green'}}>Close</Text>
      </Pressable>
      {sharedMimeType === 'text/plain' && <Text>{sharedData}</Text>}
      {sharedMimeType.startsWith('image/') && (
        <Image
          style={{width: '100%', height: 200}}
          resizeMode="contain"
          source={{uri: sharedData}}
        />
      )}
    </View>
  );
};

export default Share;
