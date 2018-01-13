module Customers.Grid exposing (view)

import Html exposing (Html, text, div)
import Html.Attributes exposing (style)
import Material.Card as Card
import Material.Options as Options exposing (cs, css, onClick)
import Material.Color as Color
import Material.Typography as Typography
import Firebase.DB
import Debug as D exposing (log)
import Models.Customer exposing(Customer)
import Dict
import Msg exposing(Msg(ChangeRoute))
import Routing exposing(Route(CustomerDetailRoute))


white : Options.Property c m
white =
    Color.text Color.white


margin1 : Options.Property a b
margin1 =
    css "margin" "0"


anMdlCard : Customer -> Html Msg
anMdlCard customer =
    Card.view
        [ css "width" "256px"
        , css "height" "256px"
        , css "padding" "5px"
        , css "background" ("url('" ++ customer.pictureUrl ++ "') center / cover")
        , margin1
        , onClick (ChangeRoute (CustomerDetailRoute customer.id))
        ]
        [ Card.text [ Card.expand ] []
          -- Filler
        , Card.text
            [ css "background" "rgba(0, 0, 0, 0.5)" ]
            -- Non-gradient scrim
            [ Options.span
                [ white, Typography.title, Typography.contrast 1.0 ]
                [ text customer.fullname ]
            ]
        ]


contentStyle : Html.Attribute Msg
contentStyle =
    style
        [ ( "display", "flex" )
        , ( "width", "100%" )
        , ( "justify-content", "space-around" )
        , ( "align-items", "flex-start" )
        , ( "flex-flow", " row wrap " )
        ]


view model =
    div [ contentStyle ]
        (List.map (\customer -> anMdlCard customer) (model.customersById |> Dict.values))

