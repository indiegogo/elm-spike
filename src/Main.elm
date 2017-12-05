module Main exposing (main)

import Core exposing (update, view, init, subscriptions, delta2url, location2messages, Model)
import Msg exposing (Msg)
import RouteUrl as Routing


main : Routing.RouteUrlProgram Never Model Msg
main =
    Routing.program
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
