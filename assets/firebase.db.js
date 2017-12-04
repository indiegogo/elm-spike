// Pure Javascript functions to act as a stop-gap for pure firebase elm support
// assumes that this is part of the dom first.
//
// <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
//
// as well as the local bootstrap code ;
//
// <script src="/assets/firebase.setup.js"></script>
// globals: firebase

let FirebaseDBPort = function(fromFirebaseDBPort, elmPort) {
  let flattenWithId = function(thing) {
    let customersWithKey = [];
    for (let member in thing) {
      let tmp = thing[member];
      tmp.id = member;
      customersWithKey.push(tmp);
    }
    return customersWithKey;
  };

  let customerCreate = function(user_ob) {
    var database = firebase.database();
    var nextKey = database.ref().child("customers").push().key;
    let updates = {};
    updates["/customers/" + nextKey] = user_ob;

    database.ref().update(updates).then(function() {
      console.log("update success" + nextKey);
      // update customer list fresh (simple case)
      getCustomers();
    }).catch(function() {
      console.log("update fail" + nextKey);
      // getCustomers()
      // let know failure
    });
  };
  let getCustomers = function() {
    var database = firebase.database();
    database.ref().child("customers").once("value").then((customers) => {
      let customersWithKey = flattenWithId(customers.val() || []);
      fromFirebaseDBPort.send(
        customersWithKey
      );
    });
  };

  let initalizeRealtimeCustomerUpdates = function() {
    var database = firebase.database();
    database.ref().child("customers").on("value",function(snapshot) {
      fromFirebaseDBPort.send(
        flattenWithId(snapshot.val() || [])
      );

    });
  };

  let initializeElmSubscripton = function() {
    elmPort.subscribe(function(msg) {
      console.log("DB :: Chomp Chomp .. got a message from Elm :: ", msg);
      switch (msg[0]) {
      case "Database/Customer/Create":
        console.log("Database create ", msg[1]);
        customerCreate(msg[1]);
        break;
      case "Database/Customer/List":
        getCustomers();
        break;
      }
    });

  };

  initalizeRealtimeCustomerUpdates();
  initializeElmSubscripton();

};
