module Msg exposing (Msg(..))

import Empty exposing (Msg)
import Customers exposing (Msg)
import SignIn exposing (Msg)
import Firebase.DB exposing(Msg)

type Msg
    = SelectPage Int
    | CustomersPage Customers.Msg
    | EmptyPage Empty.Msg
    | SignInPage SignIn.Msg
    | FirebaseDBPage Firebase.DB.Msg
