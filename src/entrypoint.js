import Elm from './Main.elm';

import * as firebase from "../assets/firebase.js";
import {SetupFirebase} from "../assets/firebase.setup.js";
import {FirebaseAuthPort} from "../assets/firebase.auth.js";
import {FirebaseDBPort} from "../assets/firebase.db.js";


SetupFirebase(firebase);

const elm = Elm.Main.fullscreen();
console.log(elm.ports);

let elmPortAuth = elm.ports.toFirebaseAuth;
let elmPortDB = elm.ports.toFirebaseDB;

let dbElmSendPort  = elm.ports.fromFirebaseDB;
let authElmSendPort = elm.ports.fromFirebaseAuth;


if (elmPortAuth && authElmSendPort) {
  FirebaseAuthPort(firebase, authElmSendPort, elmPortAuth);
}

if (elmPortDB && dbElmSendPort) {
  FirebaseDBPort(firebase, dbElmSendPort, elmPortDB);
}
