module Msg exposing (Msg(..))

import Maybe
import Route exposing (Route)
import Data.User as User exposing (User)


type Msg
    = SetRoute (Maybe Route)
    | SetUser (Maybe User)
