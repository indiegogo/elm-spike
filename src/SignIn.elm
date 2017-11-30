module SignIn exposing (view, update,Msg, Model, SessionState(..), initModel)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Debug as D

type Msg
    = SignInMsg
    | SignUpMsg
    | SetUsername String
    | SetPassword String
    | SetPasswordConfirmation String




type SessionState
    = InValid
    | Verifying
    | Valid


type alias Model =
    { username : String
    , password : String
    , state : SessionState
    }


initModel =
    Model "" "" InValid


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
        , ( "margin-left", "10px" )
        , ( "border-radius", "8px" )
        ]


signInStyle =
    style
        [ ( "display", "flex" )
        , ( "justify-content", "center" )
        , ( "align-items", "center" )
        , ( "flex-direction", "column" )
        , ( "margin-top", "50px" )
        ]


wrapperStyle =
    style
        [ ( "min-width", "500px" )
        ]


view model =
    div [ signInStyle ]
        [ div [ wrapperStyle ]
            [ input [ inputStyle, name "username", type_ "text", placeholder "username", (onInput SetUsername) ] []
            ]
        , div [ wrapperStyle ]
            [ input [ inputStyle, name "password", type_ "password", placeholder "password", (onInput SetPassword) ] []
            , button [ buttonStyle, (onClick SignInMsg) ] [ text "Sign In" ]
            ]
        , div [ wrapperStyle ]
            [ input
                [ inputStyle
                , name "password_confirm"
                , type_ "password"
                , placeholder "password confirmation"
                , onInput SetPasswordConfirmation
                ]
                []
            , button [ buttonStyle, (onClick SignUpMsg) ] [ text "Sign Up" ]
            ]
        ]


update msg model =
    case msg of
        SignInMsg ->
            ( { model | state = Valid }, Cmd.none )

        SignUpMsg ->
            ( model, Cmd.none )

        SetUsername str ->
            ( { model | username = str }, Cmd.none )

        SetPassword str ->
            ( { model | password = str }, Cmd.none )

        SetPasswordConfirmation str ->
            ( model, Cmd.none )
