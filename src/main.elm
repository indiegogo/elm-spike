module Main exposing (main)

import Reactor exposing (update, view, init, subscriptions)
import Navigation exposing (Location)
import Route
import Msg exposing (Msg(..))


main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
