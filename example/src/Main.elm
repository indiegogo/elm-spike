module Main exposing (main)

import Widget
import Html exposing (Html, text, program, div)

type Msg =
    Widget Widget.Msg

type alias Model = {
        wModel : Widget.Model
    }

main =
    Html.program {
        init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
    }
    
init =
    ({
        wModel = Widget.initModel
    }, Cmd.none)
    
view model =
    div []
        [ text "hi this is a basic as possible for a html program"
          , (Html.map Widget (Widget.view model.wModel))
        --  (Html.map Widget (Widget.view model.wModel))
        --  could also be written with the funky composition operators like:
        --  .wModel >> Widget.view >> Html.map Widget <| model
        ]
    
update msg model =
    case msg of
        Widget wMsg ->
            let
                next = Widget.update wMsg model.wModel
                newWidgetModel    = Tuple.first next
                widgetCmd    = Tuple.second next |> Cmd.map Widget
            in
                ({model|wModel = newWidgetModel}, widgetCmd)

subscriptions model =
    Sub.none
    

