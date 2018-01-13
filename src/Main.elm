module Main exposing (main)

import Core
import Msg exposing (Msg)

import Navigation exposing (Location)
import Routing

{-
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
-}

main : Program Never Core.Model Msg
main =
    Navigation.program Msg.OnLocationChange
        { init = init
        , view = Core.view
        , update = Core.update
        , subscriptions = Core.subscriptions
        }

init : Location -> ( Core.Model, Cmd Msg )
init location =
    let

        currentRoute =
            Debug.log "location" (Routing.parseLocation location)
    in
        (Core.initModelWithRoute currentRoute,
             Core.init |> Tuple.second)

