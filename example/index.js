/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import Share from './Share';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
AppRegistry.registerComponent('ShareMenuModuleComponent', () => Share);
