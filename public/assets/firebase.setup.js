// Pure Javascript functions to act as a stop-gap for pure firebase elm support
// assumes that this is part of the dom first.
//
// <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
//
//
//
// globals: firebase
(function() {
  function initializeFirebase() {
    var config = {
      apiKey: "AIzaSyCpzjTw3OkgA8-eYit7kUUte8dNiITYXLA",
      authDomain: "elm-spike.firebaseapp.com",
      databaseURL: "https://elm-spike.firebaseio.com",
      projectId: "elm-spike",
      storageBucket: "elm-spike.appspot.com",
      messagingSenderId: "799675640107"
    };
    firebase.initializeApp(config);
  }
  initializeFirebase();
}());
