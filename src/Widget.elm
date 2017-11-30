module Widget exposing (view, initModel, update, Msg, Model, main)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing(..)


type Msg
    = Interact
    | Input String

type alias Model =
    { name : String
    , counter : Int
    }

initModel : Model
initModel = {name = "Widget1" , counter = 0}


main =
    Html.program {
            init = (initModel, Cmd.none)
           , update = update
           , view = view
           , subscriptions = \(_) -> Sub.none
        }

-- using model type constructor
-- could also write this as a record format
-- {name = "widget1", counter = 0}

view: Model -> Html Msg
view model =
    div []
        [ div [ onClick Interact ]
            [ "This widget (" ++ model.name ++ ") has been interacted with " ++ (toString model.counter) ++ " Times" |> text
            ]
        , input [ onInput Input, value model.name ] []
        ]

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Interact ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Input str ->
            ( { model | name = str, counter = 0 }, Cmd.none)
