module Msg exposing (Msg(..))

import Empty exposing (Msg)
import SignIn exposing (Msg)
import Firebase.DB exposing(Msg)
import Customers.DetailList
import Navigation exposing (Location)
import Routing exposing(Route)

type Msg
    = OnLocationChange Location
    | ChangeRoute Route
    | EmptyPage Empty.Msg
    | SignInPage SignIn.Msg
    | FirebaseDBPage Firebase.DB.Msg
    | FirebaseDBSubscription Firebase.DB.Msg
    | CustomersDetailListPage Customers.DetailList.Actions
