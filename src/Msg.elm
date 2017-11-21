module Msg exposing (Msg(..))

import Empty exposing (Msg)
import Customers exposing (Msg)

type Msg
    = SelectTab Int
    | CustomersTab Customers.Msg
    | EmptyTab Empty.Msg
    | SignInMsg
    | SignUpMsg
