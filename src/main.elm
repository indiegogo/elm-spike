module Main exposing (main)

import Reactor exposing(update, view, init, subscriptions)
import Html exposing(Html)
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
