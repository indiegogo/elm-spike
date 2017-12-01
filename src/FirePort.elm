port module FirePort exposing (main, initModel, update, view, subscriptions, Msg(..), Model)

--
-- how elm ports work
-- https://hackernoon.com/how-elm-ports-work-with-a-picture-just-one-25144ba43cdd

import Html
import Html.Events
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode


port toFirebase : ( String, Maybe Value ) -> Cmd msg


port fromFirebaseAuth : (Value -> msg) -> Sub msg


port fromFirebaseDB : (Value -> msg) -> Sub msg


type FirebaseMsg
    = Login
    | Logout
    | Create Value


type Msg
    = AuthFromFirebase (Maybe User)
    | FireBase FirebaseMsg
    | FirebaseDBUpdate String


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
    , dbMsg : String
    }


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { status = Verifying, user = Nothing, dbMsg = "" }


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

viewDbMsg model=
    Html.div [] [Html.text "Last DB Message ", Html.text model.dbMsg  ]

viewVerifying =
    Html.div [] [ Html.text "..initializing auth provider" ]


viewLoggedOut model =
    Html.div []
        [ Html.button [ Html.Events.onClick (FireBase Login) ] [ Html.text "Trigger Login Flow with Firebase" ]
        , Html.div [] [ Html.text (.user >> toString <| model) ]

        ]


viewLoggedIn model =
    Html.div []
        [ Html.div [] [Html.text "Current User is " ,Html.text (.user >> toString <| model) ]
        , Html.button [ Html.Events.onClick (FireBase Logout) ] [ Html.text "Logout" ]
        , Html.button [ Html.Events.onClick (FireBase (Create newUser)) ] [ Html.text "Create User" ]
        , viewDbMsg model
        ]


newUser =
    Encode.object
        [ ( "name", Encode.string "Detective Sam Spade" )
        , ( "birthday", Encode.string "11/02/1979" )
        ]



-- https://staltz.com/unidirectional-user-interface-architectures.html


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        FirebaseDBUpdate lastUpdateMessage ->
            ( { model | dbMsg = lastUpdateMessage }, Cmd.none )

        AuthFromFirebase maybeUser ->
            case maybeUser of
                Nothing ->
                    ( { model | status = NoAuth, user = Nothing }, Cmd.none )

                Just _ ->
                    ( { model | user = maybeUser, status = Auth }, Cmd.none )

        FireBase Login ->
            ( model, toFirebase ( "Trigger/Login", Nothing ) )

        FireBase Logout ->
            ( model, toFirebase ( "Trigger/Logout", Nothing ) )

        FireBase (Create valueObject) ->
            ( model, toFirebase ( "Database/User/Create", Just valueObject ) )


subscriptions _ =
    Sub.batch
        [ fromFirebaseAuth (decodeFirebaseValue)
        , fromFirebaseDB (decodeFirebaseDBValue)
        ]


decodeFirebaseDBValue v =
    let
        result =
            Decode.decodeValue Decode.string v
    in
        case result of
            Ok string ->
                FirebaseDBUpdate string

            Err msg ->
                FirebaseDBUpdate ("Unknown Error :" ++ (toString msg))


decodeFirebaseValue v =
    let
        result =
            Decode.decodeValue Decode.string v
    in
        case result of
            Ok string ->
                AuthFromFirebase (Just { email = string })

            Err msg ->
                AuthFromFirebase Nothing
