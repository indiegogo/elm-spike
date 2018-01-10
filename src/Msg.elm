module Msg exposing (Msg(..))

import Empty exposing (Msg)
import Customers.Grid exposing (Msg)
import SignIn exposing (Msg)
import Firebase.DB exposing(Msg)
import Firebase.Auth exposing(Model)
import Customers.DetailList

type Msg
    = SelectPage Int
    | CustomersPage Customers.Grid.Msg
    | EmptyPage Empty.Msg
    | SignInPage SignIn.Msg
    | FirebaseDBPage Firebase.DB.Msg
    | FirebaseDBSubscription Firebase.DB.Msg
    | CustomersDetailListPage Customers.DetailList.Actions
