port module Firebase.Auth
    exposing
        ( main
        , initModel
        , update
        , view
        , subscriptions
        , AuthStatus(..)
        , Msg(UI)
        , FirebaseMsg(Logout) -- https://github.com/elm-lang/elm-lang.org/issues/523
        , Model
        , authorized
        )

--
-- how elm ports work
-- https://hackernoon.com/how-elm-ports-work-with-a-picture-just-one-25144ba43cdd

import Html
import Html.Events
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode
import Json.Encode
import Json.Decode



port toFirebaseAuth : ( String, Maybe Value ) -> Cmd msg


port fromFirebaseAuth : (Value -> msg) -> Sub msg


type FirebaseMsg
    = Login
    | Logout


type Msg
    = AuthFromFirebase (Maybe User)
    | UI FirebaseMsg


type AuthStatus
    = Verifying
    | NoAuth
    | Auth


type alias User =
    { email : String
    }


type alias Model =
    { status : AuthStatus
    , user : Maybe User
    }


authorized : Model -> Bool
authorized model =
    case model.status of
        Auth ->
            True

        _ ->
            False


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { status = NoAuth -- Verifying -> NoAuth | Auth
    , user = Nothing
    }


init =
    ( initModel, Cmd.none )


view model =
    case model.status of
        Verifying ->
            viewVerifying

        NoAuth ->
            viewLoggedOut model

        Auth ->
            viewLoggedIn model


viewVerifying =
    Html.div [] [ Html.text "..initializing auth provider" ]


viewLoggedOut model =
    Html.div []
        [ Html.button [ Html.Events.onClick (UI Login) ] [ Html.text "Trigger Login Flow with Firebase" ]
        ]


viewLoggedIn model =
    Html.div []
        [ Html.div [] [ Html.text "Current User is ", Html.text (.user >> toString <| model) ]
        , Html.button [ Html.Events.onClick (UI Logout) ] [ Html.text "Logout" ]
        ]



-- https://staltz.com/unidirectional-user-interface-architectures.html


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        AuthFromFirebase maybeUser ->
            case maybeUser of
                Nothing ->
                    ( { model | status = NoAuth, user = Nothing }, Cmd.none )

                Just _ ->
                    ({ model | user = maybeUser, status = Auth }, Cmd.none)

        UI Login ->
            ( {model| status = Verifying}, toFirebaseAuth ( "Trigger/Login", Nothing ) )

        UI Logout ->
            ( { model | status = NoAuth, user = Nothing }, toFirebaseAuth ( "Trigger/Logout", Nothing ) )
        

subscriptions _ =
    fromFirebaseAuth (decodeFirebaseValue)


decodeFirebaseValue value =
    let
        result =
            Decode.decodeValue Decode.string value
    in
        case result of
            Ok string ->
                AuthFromFirebase (Just { email = string })

            Err msg ->
                AuthFromFirebase Nothing
