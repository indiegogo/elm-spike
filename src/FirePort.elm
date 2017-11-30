-- I have to read this everytime i make a port
--
-- https://hackernoon.com/how-elm-ports-work-with-a-picture-just-one-25144ba43cdd
--


port module FirePort exposing (main, initModel, update, view, subscriptions, Msg(..), Model)

import Html
import Html.Events
import Html.Attributes
import Json.Encode exposing (Value)
import Json.Decode as Decode


port toFirebase : String -> Cmd msg
port fromFirebase : (Value -> msg) -> Sub msg
port tacoTruck : String -> Cmd msg

type FirebaseMsg
    = Login
    | Logout


type Msg
    = UpdateElmFromFirebase (Maybe User)
    | FirebaseAuth FirebaseMsg
    | AnythingElse 


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


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { status = Verifying, user = Nothing }


init =
    ( initModel, Cmd.none )

view model =
    case model.status of
        Verifying ->
            Html.div [] [ Html.text "..initializing auth provider" ]

        NoAuth ->
            Html.div []
                [ Html.button [ Html.Events.onClick (FirebaseAuth Login) ] [ Html.text "Trigger Login Flow with Firebase" ]
                , Html.div [] [ Html.text (.user >> toString <| model) ]
                ]

        Auth ->
            renderLoggedIn model

renderLoggedIn model =
  Html.div []
      [ Html.div [] [ Html.text (.user >> toString <| model) ]
      , Html.button [ Html.Events.onClick (FirebaseAuth Logout) ] [ Html.text "Logout"]
      ]

-- https://staltz.com/unidirectional-user-interface-architectures.html
update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        UpdateElmFromFirebase maybeUser ->
            case maybeUser of
                Nothing ->
                    ( { model | status = NoAuth, user = Nothing}, Cmd.none )

                Just _ ->
                    ( { model | user = maybeUser, status = Auth }, Cmd.none )

        FirebaseAuth Login ->
            ( model, toFirebase "Trigger/Login" )

        FirebaseAuth Logout ->
            ( model, toFirebase "Trigger/Logout" )
        AnythingElse ->
            ( model, Cmd.none)


subscriptions _ =
    fromFirebase (decodeFirebaseValue)


decodeFirebaseValue v =
    let
        result =
            Decode.decodeValue Decode.string v
    in
        case result of
            Ok string ->
                UpdateElmFromFirebase (Just { email = string })

            Err msg ->
                UpdateElmFromFirebase Nothing
