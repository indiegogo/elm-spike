'use strict';


const Elm = require('./Main.elm');
console.log(Elm)
const firebase = require("firebase"); /* npm */
const {SetupFirebase} = require("../assets/firebase.setup.js");
const {FirebaseAuthPort} = require("../assets/firebase.auth.js");
const {FirebaseDBPort} = require("../assets/firebase.db.js");
console.log(SetupFirebase)

require('./index.html');
require('../assets/syntax_sugar.png')
require('../assets/material.grey-lime.min.css')
require('../assets/material.orange-light_blue.min.css')

SetupFirebase(firebase);

const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const elm = Elm.Main.embed(mountNode);

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
