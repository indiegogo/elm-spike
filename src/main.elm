module Main exposing (..)

import Html exposing (Html, div, text, ul)
import Contact.Json exposing (Contact)
import Contact exposing(fred, wilma)
import Element
import Element.Attributes
import Style
import Style.Color as Color
import Style.Font as Font
import Style.Border as Border
import Color exposing (black, white, lightGrey)

type alias Model =
    { contacts : List Contact
    }


init : ( Model, Cmd msg )
init =
    ( { contacts =
            [ fred, wilma ]
      }
    , Cmd.none
    )


main : Program Never Model msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )

-- We need a type that represents out style identifiers. 
-- These act like css classes
type MyStyles
    = CardStyle | NoStyle

-- We define our stylesheet
stylesheet =
    Style.styleSheet
        [
         
         Style.style CardStyle
            [ Color.text lightGrey
            , Color.background black
            , Font.size 16 -- all units given as px
            , Font.typeface
                [ Font.font "Helvetica"
                , Font.font "Comic Sans"
                , Font.font "Papyrus"
                ]
            ]
          , Style.style NoStyle
             [
              Border.all 1
             , Border.solid
             ,  Color.border black
             ]
        ]

view : Model -> Html msg
view model =
    Element.layout stylesheet <|
      viewContacts CardStyle model


viewContacts style model =
    Element.grid
        NoStyle
        [Element.Attributes.spacing 1, Element.Attributes.padding 1 ]
 { columns = [ Element.Attributes.px 100, Element.Attributes.px 100, Element.Attributes.px 100, Element.Attributes.px 100 ]
        , rows =
            [ Element.Attributes.px 100
            , Element.Attributes.px 100
            , Element.Attributes.px 100
            , Element.Attributes.px 100
            ]
        , cells =
            [ Element.cell
                { start = ( 0, 0 )
                , width = 1
                , height = 1
                , content = (Element.el NoStyle [] (Element.text "1 Name 0 0"))
                }
            , Element.cell
                { start = ( 1, 1 )
                , width = 1
                , height = 2
                , content = (Element.el NoStyle [ Element.Attributes.spacing 100 ] (Element.text "2 Email 1 1"))
                }
            , Element.cell
                { start = ( 2, 1 )
                , width = 2
                , height = 2
                , content = (Element.el NoStyle [] (Element.text "3 Address 2 1"))
                }
            , Element.cell
                { start = ( 1, 0 )
                , width = 1
                , height = 1
                , content = (Element.el NoStyle [] (Element.text "4 City 1 0"))
                }
            ]
        }
        --(List.map (\d -> viewContact style d ) model.contacts)



viewContact style contact =
    -- An el is the most basic element, like a <div>
    Element.el style [] (Element.text contact.name )

subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none
