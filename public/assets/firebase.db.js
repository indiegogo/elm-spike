// Pure Javascript functions to act as a stop-gap for pure firebase elm support
// assumes that this is part of the dom first.
//
// <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
//
// as well as the local bootstrap code ;
//
// <script src="/assets/firebase.setup.js"></script>
// globals: firebase

const FirebaseDBPort = function(fromFirebaseDBPort, elmPort) {
  const flattenWithId = function(thing) {
    let customersWithKey = [];
    for (let member in thing) {
      let tmp = thing[member];
      tmp.id = member;
      customersWithKey.push(tmp);
    }
    return customersWithKey;
  };

  const importCustomers = function(list) {
    disableRealtimeUpdates();
    for(let i in list) {
      const c = list[i];
      customerCreate(c); 
    }
    getCustomers();
    enableRealtimeUpdates();
  };

  const customerCreate = function(user_ob) {
    
    const database = firebase.database();
    let nextKey = user_ob.id;
    if (!nextKey) {
      nextKey = database.ref().child("customers").push().key;
    }
    
    let updates = {};
    updates["/customers/" + nextKey] = user_ob;

    database.ref().update(updates).then(function() {
      console.log("update success" + nextKey);
    }).catch(function() {
      console.log("update fail" + nextKey);

    });
  };

  const getCustomers = function() {
    const database = firebase.database();
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

  const deleteCustomer = function(customerId) {
    const database = firebase.database();
    database.ref().child("customers/" + customerId).remove().then(() => {
      console.log("Deleted: " + customerId);
    });
  };

  let realtimeUpdateCount = 0;

  const enableRealtimeUpdates = function() {
    console.log("Turning ON Realtime Updates ")
    const database = firebase.database();
    database.ref().child("customers").on("value",updateCustomer);
  }

  const disableRealtimeUpdates = function() {
    console.log("Turning OFF Realtime Updates ")
    const database = firebase.database();
    database.ref().child("customers").off("value",updateCustomer);
  }

  const updateCustomer = function(snapshot) {
    realtimeUpdateCount++;
    console.log("Realtime Fired Count: " + realtimeUpdateCount);
    fromFirebaseDBPort.send(
      flattenWithId(snapshot.val() || [])
    );
  }

  const initalizeRealtimeCustomerUpdates = function() {
    enableRealtimeUpdates();
  };

  const initializeElmSubscripton = function() {
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
