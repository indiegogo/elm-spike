port module FirePort
    exposing
        ( main
        , initModel
        , update
        , view
        , subscriptions
        , Msg(..)
        , Model
        , viewLoggedOut
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
import Json.Decode.Pipeline as DecodePipeline


-- elm-package install -- yes noredink/elm-decode-pipeline

import Json.Decode.Pipeline


port toFirebase : ( String, Maybe Value ) -> Cmd msg


port fromFirebaseAuth : (Value -> msg) -> Sub msg


port fromFirebaseDB : (Value -> msg) -> Sub msg


type FirebaseMsg
    = Login
    | Logout
    | CreateCustomer Value
    | CustomerList


type Msg
    = AuthFromFirebase (Maybe User)
    | FireBase FirebaseMsg
    | FirebaseCustomerList (List FirebaseCustomer)
    | FirebaseErrorMessage String


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
    , all : List FirebaseCustomer
    }

authorized: Model -> Bool
authorized model =
    case model.status of
        Auth ->
           True
        _ ->
           False

main: Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { status = Verifying
    , user = Nothing
    , all = []
    , dbMsg = ""
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


viewDbMsg model =
    Html.div [] [ Html.text "Last DB Message ", Html.text model.dbMsg ]


viewVerifying =
    Html.div [] [ Html.text "..initializing auth provider" ]


viewLoggedOut model =
    Html.div []
        [ Html.button [ Html.Events.onClick (FireBase Login) ] [ Html.text "Trigger Login Flow with Firebase" ]
        , Html.div [] [ Html.text (.user >> toString <| model) ]
        ]


viewLoggedIn model =
    Html.div []
        [ Html.div [] [ Html.text "Current User is ", Html.text (.user >> toString <| model) ]
        , Html.button [ Html.Events.onClick (FireBase Logout) ] [ Html.text "Logout" ]
        , Html.button [ Html.Events.onClick (FireBase (CreateCustomer newCustomer)) ] [ Html.text "Create User" ]
        , viewDbMsg model
        , viewCustomers model.all
        ]


viewCustomers list =
    Html.ul []
        (List.map
            (\customer ->
                Html.li []
                    [ Html.text customer.name
                    , Html.text customer.birthday
                    , Html.text customer.company
                    ]
            )
            list
        )


newCustomer =
    Encode.object
        [ ( "name", Encode.string "Detective Sam Spade" )
        , ( "birthday", Encode.string "11/02/1979" )
        , ( "company", Encode.string "Syntax Sugar Inc." )
        ]



-- https://staltz.com/unidirectional-user-interface-architectures.html


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        FirebaseCustomerList all ->
            ( { model | all = all }, Cmd.none )

        FirebaseErrorMessage lastUpdateMessage ->
            ( { model | dbMsg = lastUpdateMessage }, Cmd.none )

        AuthFromFirebase maybeUser ->
            case maybeUser of
                Nothing ->
                    ( { model | status = NoAuth, user = Nothing }, Cmd.none )

                Just _ ->
                    update (FireBase CustomerList) { model | user = maybeUser, status = Auth }

        FireBase Login ->
            ( model, toFirebase ( "Trigger/Login", Nothing ) )

        FireBase Logout ->
            ( {model| status = NoAuth, user = Nothing }, toFirebase ( "Trigger/Logout", Nothing ) )

        FireBase CustomerList ->
            ( model, toFirebase ( "Database/Customer/List", Nothing ) )

        FireBase (CreateCustomer valueObject) ->
            ( model, toFirebase ( "Database/Customer/Create", Just valueObject ) )


subscriptions _ =
    Sub.batch
        [ fromFirebaseAuth (decodeFirebaseValue)
        , fromFirebaseDB (decodeFirebaseDBValue)
        ]


decodeFirebaseDBValue v =
    let
        result =
            Decode.decodeValue decodeFirebaseCustomerList v

        -- to change
    in
        case result of
            Ok thing ->
                FirebaseCustomerList thing

            Err msg ->
                FirebaseErrorMessage ("Unknown Error :" ++ (toString msg))


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


type alias FirebaseCustomer =
    { birthday : String
    , company : String
    , name : String
    , id : String
    }


decodeFirebaseCustomerList : Decode.Decoder (List FirebaseCustomer)
decodeFirebaseCustomerList =
    Decode.list decodeFirebaseCustomer


decodeFirebaseCustomer : Decode.Decoder FirebaseCustomer
decodeFirebaseCustomer =
    DecodePipeline.decode FirebaseCustomer
        |> DecodePipeline.required "birthday" (Decode.string)
        |> DecodePipeline.required "company" (Decode.string)
        |> DecodePipeline.required "name" (Decode.string)
        |> DecodePipeline.required "id" (Decode.string)


encodeFirebaseCustomer : FirebaseCustomer -> Encode.Value
encodeFirebaseCustomer record =
    Encode.object
        [ ( "birthday", Encode.string <| record.birthday )
        , ( "company", Encode.string <| record.company )
        , ( "name", Encode.string <| record.name )
        , ( "id", Encode.string <| record.id )
        ]
