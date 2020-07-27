/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */
import React, {useState, useEffect} from 'react';
import {StyleSheet, Text, View, Image} from 'react-native';
import ShareMenu from 'react-native-share-menu';

const App: () => React$Node = () => {
  const [sharedText, setSharedText] = useState('');
  const [sharedImg, setSharedImg] = useState('');

  useEffect(() => {
    ShareMenu.getSharedText((data: ?string) => {
      if (!data) {
        return;
      }

      if (data.startsWith('content://') || data.startsWith('file://')) {
        setSharedImg(data);
      } else {
        setSharedText(data);
      }
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>React Native Share Menu</Text>
      <Text style={styles.instructions}>Shared text: {sharedText}</Text>
      <Text style={styles.instructions}>Shared image:</Text>
      {sharedImg.length > 1 && (
        <Image
          style={styles.image}
          source={{uri: sharedImg}}
          resizeMode="contain"
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  image: {
    width: '100%',
    flex: 1,
  },
});

export default App;
