module Msg exposing (Msg(..))

import Empty exposing (Msg)
import CustomersGrid exposing (Msg)
import SignIn exposing (Msg)
import Firebase.DB exposing(Msg)
import Firebase.Auth exposing(Model)

type Msg
    = SelectPage Int
    | CustomersPage CustomersGrid.Msg
    | EmptyPage Empty.Msg
    | SignInPage SignIn.Msg
    | FirebaseDBPage Firebase.DB.Msg
