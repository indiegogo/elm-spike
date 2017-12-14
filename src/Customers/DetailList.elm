module Customers.DetailList exposing (main)

import Html exposing (Html, div, text)
import Models.FirebaseCustomer exposing(FirebaseCustomer)

import Array exposing(Array)
type alias Model =
    Array FirebaseCustomer
type Msg = Msg

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }

init = (Array.fromList [], Cmd.none)

view model =
    div [] [text "hi"]

subscriptions model = Sub.none

update msg model = (model,Cmd.none)
