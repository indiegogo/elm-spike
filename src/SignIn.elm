module SignIn exposing (view0)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick)

import Msg 

inputStyle =
    style
        [ ( "font-size", "2em" )
        , ( "margin-top", "1em" )
        , ( "padding", "5px" )
        , ( "border-radius", "8px" )
        ]
buttonStyle =
    style
        [ ( "font-size", "2em" )
        , ( "margin-top", "1em" )
        , ( "padding", "5px" )
        , ( "margin-left", "10px")
        , ( "border-radius", "8px" )
        ]
signInStyle =
    style
        [ ( "display", "flex" )
        , ( "justify-content", "center" )
        , ( "align-items", "center" )
        , ( "flex-direction", "column" )
        , ( "margin-top", "50px")
        ]

wrapperStyle =
    style [
         ("min-width", "500px")
        ]
view0 =
    div [ signInStyle ]
        [ div [wrapperStyle]
            [ input [ inputStyle, name "username", type_ "text", placeholder "username" ] []
            ]
        , div [wrapperStyle]
            [ input [ inputStyle, name "password", type_ "password", placeholder "password" ] []
             , button [buttonStyle, onClick (Msg.SignInMsg)] [text "Sign In"]
            ]
        , div [wrapperStyle]
            [ input
                [ inputStyle
                , name "password_confirm"
                , type_ "password"
                , placeholder "password confirmation"
                ]
                []
             , button [buttonStyle, onClick (Msg.SignUpMsg)] [text "Sign Up"]
            ]
        ]
