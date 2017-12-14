module Empty exposing (view, Msg)

import Html exposing (text, div)
import Material


type Msg
    = Mdl (Material.Msg Msg)


update msg model =
    ( model, Cmd.none )


view model =
    div [] [ text "Empty Page" ]
