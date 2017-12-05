module SignIn exposing (view, update,Msg, Model, SessionState(..), initModel, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Debug as D

import FirePort as Firebase 

type Msg
    = SignInMsg
    | SignUpMsg
    | SetUsername String
    | SetPassword String
    | SetPasswordConfirmation String
    | Firebase Firebase.Msg



type SessionState
    = InValid
    | Verifying
    | Valid


type alias Model =
    { username : String
    , password : String
    , state : SessionState
    , firebaseModel : Firebase.Model
    }


initModel =
    { username = ""
    , password = ""
    , state = InValid
    , firebaseModel = Firebase.initModel
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
             Html.map Firebase (Firebase.view model.firebaseModel)
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

        Firebase msg ->
            let
                (result, cmd) =
                    Firebase.update msg model.firebaseModel

                username =
                    case result.user of
                           Just u ->
                               u.email
                           Nothing ->
                               ""
                state =
                    case Firebase.authorized result of
                        True ->
                            Valid
                        False ->
                            InValid
            in
                ({model |
                      firebaseModel = result
                      , state = state
                      , username = username
                 }, Cmd.map Firebase cmd)

subscriptions model =
    Sub.map Firebase (Firebase.subscriptions model)

