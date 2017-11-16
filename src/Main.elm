module Main exposing (main)

import Reactor exposing (update, view, init, subscriptions, delta2url, location2messages)
import RouteUrl as Routing

main =
    Routing.program
        {
         delta2url = delta2url
        , location2messages = location2messages
        , init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
