module SignIn exposing (view, update,Msg(..), Model, SessionState(..), initModel, subscriptions)

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



type SessionState
    = InValid
    | Verifying
    | Valid

type alias Account =
    { username : String
    }


type alias Model =
    { username : String
    , password : String
    , state : SessionState
    , firebaseModel : FireAuth.Model
    , accountModel : Maybe Account
    }


initModel =
    { username = ""
    , password = ""
    , state = InValid
    , firebaseModel = FireAuth.initModel
    , accountModel = Nothing
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


update msg model =
    case msg of
        SignInMsg ->
            ( { model | state = Valid
              , accountModel = (Just (Account model.username))
              }, Cmd.none )

        SignUpMsg ->
            ( model, Cmd.none )

        SetUsername str ->
            ( { model | username = str }, Cmd.none )

        SetPassword str ->
            ( { model | password = str }, Cmd.none )

        SetPasswordConfirmation str ->
            ( model, Cmd.none )

        FireAuth msg ->
            let
                (result, cmd) =
                    FireAuth.update msg model.firebaseModel

                username =
                    case result.user of
                           Just u ->
                               u.email
                           Nothing ->
                               ""
                state =
                    case FireAuth.authorized result of
                        True ->
                            Valid
                        False ->
                            InValid

                accountModel = case state of
                                   Valid ->
                                       (Just (Account username))
                                   _ ->
                                       Nothing
            in
                ({model |
                      firebaseModel = result
                      , state = state
                      , username = username
                      , accountModel = accountModel
                 }, Cmd.map FireAuth cmd)

subscriptions model =
    Sub.map FireAuth (FireAuth.subscriptions model)

