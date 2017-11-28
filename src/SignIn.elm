module SignIn exposing (view, update,Msg, Model, SessionState(..), initModel)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Debug as D
import Http
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline

type Msg
    = SignInMsg
    | SignUpMsg
    | SetUsername String
    | SetPassword String
    | SetPasswordConfirmation String
    | VerifyAccount (Result Http.Error GithubResponse)


type alias GithubResponse =
    { id : Int
    , url : String
    , scopes : List String
    , token : String
    , token_last_eight : String
    , hashed_token : String
    , app : GithubResponseApp
    , note : String
    , note_url : String
    , updated_at : String
    , created_at : String
    , fingerprint : String
    }


type alias GithubResponseApp =
    { url : String
    , name : String
    , client_id : String
    }


decodeGithubResponse : Json.Decode.Decoder GithubResponse
decodeGithubResponse =
    Json.Decode.Pipeline.decode GithubResponse
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "url" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "scopes" (Json.Decode.list Json.Decode.string)
        |> Json.Decode.Pipeline.required "token" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "token_last_eight" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "hashed_token" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "app" (decodeGithubResponseApp)
        |> Json.Decode.Pipeline.required "note" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "note_url" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "updated_at" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "created_at" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "fingerprint" (Json.Decode.string)


decodeGithubResponseApp : Json.Decode.Decoder GithubResponseApp
decodeGithubResponseApp =
    Json.Decode.Pipeline.decode GithubResponseApp
        |> Json.Decode.Pipeline.required "url" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "client_id" (Json.Decode.string)


encodeGithubResponse : GithubResponse -> Json.Encode.Value
encodeGithubResponse record =
    Json.Encode.object
        [ ( "id", Json.Encode.int <| record.id )
        , ( "url", Json.Encode.string <| record.url )
        , ( "scopes", Json.Encode.list <| List.map Json.Encode.string <| record.scopes )
        , ( "token", Json.Encode.string <| record.token )
        , ( "token_last_eight", Json.Encode.string <| record.token_last_eight )
        , ( "hashed_token", Json.Encode.string <| record.hashed_token )
        , ( "app", encodeGithubResponseApp <| record.app )
        , ( "note", Json.Encode.string <| record.note )
        , ( "note_url", Json.Encode.string <| record.note_url )
        , ( "updated_at", Json.Encode.string <| record.updated_at )
        , ( "created_at", Json.Encode.string <| record.created_at )
        , ( "fingerprint", Json.Encode.string <| record.fingerprint )
        ]


encodeGithubResponseApp : GithubResponseApp -> Json.Encode.Value
encodeGithubResponseApp record =
    Json.Encode.object
        [ ( "url", Json.Encode.string <| record.url )
        , ( "name", Json.Encode.string <| record.name )
        , ( "client_id", Json.Encode.string <| record.client_id )
        ]


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
            ( { model | state = Verifying }, verifyUserCmd )

        SignUpMsg ->
            ( model, Cmd.none )

        SetUsername str ->
            ( { model | username = str }, Cmd.none )

        SetPassword str ->
            ( { model | password = str }, Cmd.none )

        SetPasswordConfirmation str ->
            ( model, Cmd.none )

        VerifyAccount (Err err) ->
            let
                log =
                    D.log (toString err)
            in
                case err of
                    Http.BadUrl str ->
                        ( model, Cmd.none )

                    Http.Timeout ->
                        ( model, Cmd.none )

                    Http.NetworkError ->
                        ( model, Cmd.none )

                    Http.BadStatus x ->
                        ( model, Cmd.none )

                    Http.BadPayload str x ->
                        ( model, Cmd.none )

        VerifyAccount (Ok githubResponse) ->
            let
                log =
                    D.log (toString githubResponse)
            in
                ( model, Cmd.none )


verifyUserCmd =
    Http.send VerifyAccount (
        Http.request
            { method = "PUT"
            , headers = []
            , url = "https://gogocurtis:af11e7f6ca764f77b084866cfd5c74f954aa4fea@api.github.com/authorizations/clients/2995c1dc85bca74fd3cd?client_secret=32ef2e58d4d14c5536f5fcc7a39caa2e685be02f&scope=user&note=elm-spike"
            , body = Http.emptyBody
            , expect = Http.expectJson decodeGithubResponse
            , timeout = Nothing
            , withCredentials = False
            }
      )
