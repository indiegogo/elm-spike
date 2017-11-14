module Views.Home exposing (view)

import Pages.Home as HomePage exposing (Model)
import Html.Attributes
import Html exposing (Html, text, div)
import Material
import Material.Scheme
import Material.Card as Card
import Material.Options as Options exposing (cs, css)
import Material.Color as Color
import Material.Typography as Typography

type alias Mdl =
    Material.Model


white : Options.Property c m
white =
    Color.text Color.white


margin1 : Options.Property a b
margin1 = 
    css "margin" "0"

anMdlCard =
    Card.view
        [ css "width" "256px"
        , css "height" "256px"
        , css "background" "url('https://2.bp.blogspot.com/-CAtiru0_Wgk/V7PgKQQ3e1I/AAAAAAAF85Y/KI-9G5903Gg7y_Wog47Ogib3f-Gc22kWwCLcB/s1600/cupcake-778704_960_720.png') center / cover"
        , margin1
        ]
        [ Card.text [ Card.expand ] []
          -- Filler
        , Card.text
            [ css "background" "rgba(0, 0, 0, 0.5)" ]
            -- Non-gradient scrim
            [ Options.span
                [ white, Typography.title, Typography.contrast 1.0 ]
                [ text "Mary Moo" ]
            ]
        ]


view : HomePage.Model -> Html msg
view model =
    div []
        [ text
            ("Views.Home says : Welcome! You are on the '"
                ++ model.name
                ++ "'"
            )
        , anMdlCard
        , anMdlCard
        ]
