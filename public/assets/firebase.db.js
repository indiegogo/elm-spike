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

  let importCustomers = function(list) {
    for(let i in list) {
      let c = list[i];
       customerCreate(c, false); 
    }
    getCustomers();
  }

  let customerCreate = function(user_ob, get = false) {
    
    var database = firebase.database();
    var nextKey = user_ob.id;
    if (!nextKey) {
      nextKey = database.ref().child("customers").push().key;
    }
    
    let updates = {};
    updates["/customers/" + nextKey] = user_ob;

    database.ref().update(updates).then(function() {
      console.log("update success" + nextKey);
      // update customer list fresh (simple case)
      if (get) {
        getCustomers();
      }
    }).catch(function() {
      console.log("update fail" + nextKey);
      // getCustomers()
      // let know failure
    });
  };

  let getCustomers = function() {
    var database = firebase.database();
    database.ref().child("customers").once("value").then((customers) => {
      console.log("get customers ok");
      let customersWithKey = flattenWithId(customers.val() || []);
      fromFirebaseDBPort.send(
        customersWithKey
      );
    }).catch(function(err){
      console.log("get customers fail", err);
    });
  };

  let deleteCustomer = function(customerId) {
    var database = firebase.database();
    database.ref().child("customers/" + customerId).remove().then(() => {
      console.log("Deleted: " + customerId);
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
      case "Database/Import/Customers":
        console.log("Import ", msg[1]);
        importCustomers(msg[1]);
        break;
      case "Database/Customer/Delete":
        console.log("Please delete: ", msg[1]);
        deleteCustomer(msg[1]);
        break;
      }
    });

  };

  initalizeRealtimeCustomerUpdates();
  initializeElmSubscripton();

};
