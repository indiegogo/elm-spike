module Msg exposing (Msg(..))

import Empty exposing (Msg)
import Customers exposing (Msg)
import SignIn exposing (Msg)

type Msg
    = SelectPage Int
    | CustomersPage Customers.Msg
    | EmptyPage Empty.Msg
    | SignInPage SignIn.Msg
