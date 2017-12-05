module SimpleWithWidget exposing (main)

import Widget
import Html exposing (Html, text, program, div)


type MainMessage
    = Widget Widget.Msg

type alias Model =
    { wModel : Widget.Model
    }


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \(model) -> Sub.none
        }


init =
    ( { wModel = Widget.initModel
      }
    , Cmd.none
    )


view model =
    let
        children =
            [ (Html.map Widget (Widget.view (model.wModel)))
            , text "hi this is a basic as possible for a html program"
            ]
        result = div [] children
    in
        result

update msg model =
    case msg of
        Widget wMsg ->
            let
                next =
                    Widget.update wMsg model.wModel

                newWidgetModel =
                    Tuple.first next

                widgetCmd =
                    Cmd.map Widget (Tuple.second next)
            in
                ( { model | wModel = newWidgetModel }, widgetCmd )


