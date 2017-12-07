module SignIn exposing (view, update,Msg(..), Model, initModel, subscriptions, ExternalMsg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Debug as D

import Firebase.Auth as FireAuth exposing (Msg)

type Msg
    = SignInMsg
    | SignUpMsg
    | SetUsername String
    | SetPassword String
    | SetPasswordConfirmation String
    | FireAuth FireAuth.Msg

type ExternalMsg =
     NoOp
    | EstablishSession FireAuth.Model

(=>): a -> b -> (a, b)
(=>) =
    (,)

type alias Account =
    { username : String
    }


type alias Model =
    { username : String
    , password : String
    , firebaseModel : FireAuth.Model
    }


initModel =
    { username = ""
    , password = ""
    , firebaseModel = FireAuth.initModel
    }


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
        , div [wrapperStyle ]
            [
             Html.map FireAuth (FireAuth.view model.firebaseModel)
            ]
        ]

update: Msg -> Model -> ((Model, Cmd Msg), ExternalMsg)
update msg model =
    case msg of
        SignInMsg ->
             model
             => Cmd.none
             => NoOp

        SignUpMsg ->
            model
            => Cmd.none
            => NoOp

        SetUsername str ->
             { model | username = str }
             => Cmd.none
             => NoOp

        SetPassword str ->
             { model | password = str} => Cmd.none => NoOp

        SetPasswordConfirmation str ->
             model => Cmd.none => NoOp

        FireAuth msg ->
            let
                (result, cmd) =
                    FireAuth.update msg model.firebaseModel
            in
                {model |
                      firebaseModel = result
                 }
                => Cmd.map FireAuth cmd
                => (EstablishSession result)

subscriptions model =
    Sub.map FireAuth (FireAuth.subscriptions model)

