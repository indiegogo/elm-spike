import './css/normalize.css';
import './css/main.css';
import '../public/assets/firebase.js'
import '../public/assets/firebase.setup.js'
import '../public/assets/firebase.auth.js'
import '../public/assets/firebase.db.js'

import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var elm = Main.embed(document.getElementById('root'));

console.log(elm.ports);

let elmPortAuth = elm.ports.toFirebaseAuth;
let elmPortDB = elm.ports.toFirebaseDB;

let dbElmSendPort  = elm.ports.fromFirebaseDB;
let authElmSendPort = elm.ports.fromFirebaseAuth;

if (elmPortAuth && authElmSendPort) {
  FirebaseAuthPort(authElmSendPort, elmPortAuth);
};

if (elmPortDB && dbElmSendPort) {
 FirebaseDBPort(dbElmSendPort, elmPortDB);
};


registerServiceWorker();
