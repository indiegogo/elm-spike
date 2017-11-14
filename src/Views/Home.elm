module Views.Home exposing (view)

import Pages.Home as HomePage exposing (Model)
import Html.Attributes
import Html exposing (Html, text, div)




view : HomePage.Model -> Html msg
view model =
    div []
        [ text
            ("Views.Home says : Welcome! You are on the '"
                ++ model.name
                ++ "'"
            )
        ]
