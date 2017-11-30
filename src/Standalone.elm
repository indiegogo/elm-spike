
module Standalone exposing (main)

import Html exposing (Html, div, program, text)
import Html.Events exposing (onClick)
import Time

import Task 

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { name : String
     , time : Maybe Time.Time
    }


type Msg
    = ChangeName
    | NewTime Time.Time


init : ( Model, Cmd Msg )
init =
    ( Model "hi" Nothing, Cmd.none )


view model =
    div [ onClick ChangeName ]
        [ "this is a html program with name " ++ model.name |> text
        ]

update msg model =
    let 
        myTask = 
            Task.perform NewTime Time.now
    in
    case msg of
        ChangeName ->
            case model.time of
                Just time ->
                    ( { model | name = ("New Name" ++ (toString time))}, myTask )
                Nothing   ->
                    ( { model | name = "New Name Without Time" }, myTask )
        NewTime time ->
            ( { model | time = Just time } , Cmd.none)
            

subscriptions model =
    Sub.none

