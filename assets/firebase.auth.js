// Pure Javascript functions to act as a stop-gap for pure firebase elm support
// assumes that this is part of the dom first.
//
// <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
//
// as well as the local bootstrap code ;
//
// <script src="/assets/firebase.setup.js"></script>
/* global: firebase */

export function FirebaseAuthPort(firebase, firebaseAuthPort, elmPort) {

    const initializeAuthStateChanged = function() {
        firebase.auth().onAuthStateChanged(function(user) {
            if (user) {
                console.log("OnAuthStateChange Fired :", user);
                firebaseAuthPort.send(user.email);
            } else {
                console.log("OnAuthStateChange Fired null User :");
                firebaseAuthPort.send(null);
            }
        });
    };

    const signInWithRedirect = function() {
        var provider = new firebase.auth.GithubAuthProvider();
        firebase.auth().signInWithRedirect(provider);
    };

    const signOut = function() {
        firebase.auth().signOut().then(function(thing) {
            console.log("signout says success ", thing);
        }).catch(function(error) {
            console.log("signout says failure ", error);
        });
        firebaseAuthPort.send(null);
    };

    const initializeElmSubscripton = function() {
        elmPort.subscribe(function(msg) {
            console.log("AUTH :: Chomp Chomp .. got a message from Elm :: ", msg);
            switch (msg[0]) {
                case "Trigger/Login":
                    signInWithRedirect();
                    break;
                case "Trigger/Logout":
                    signOut();
                    break;
            }
        });

    };

    initializeAuthStateChanged();
    initializeElmSubscripton();

};
