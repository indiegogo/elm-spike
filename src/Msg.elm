module Msg exposing (..)

import Maybe
import Route exposing (Route)
import Data.User as User exposing (User)
import Error exposing (PageError)
import Pages.Home as Home exposing(Model)

type Msg
    = SetRoute (Maybe Route)

