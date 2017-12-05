port module Firebase.DB exposing
        ( main
        , initModel
        , update
        , view
        , subscriptions
        , Msg(UI)
        , FirebaseMsg(CustomerList)
        , Model
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


port toFirebaseDB : ( String, Maybe Value ) -> Cmd msg

port fromFirebaseDB : (Value -> msg) -> Sub msg


type FirebaseMsg
    = CreateCustomer Value
    | CustomerList
    | DeleteCustomer Value


type Msg
    =  FirebaseCustomerList (List FirebaseCustomer)
    | FirebaseErrorMessage String
    | UI FirebaseMsg




type alias Model =
    {
     dbMsg : String
    , all : List FirebaseCustomer
    }


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
    {
     all = []
    , dbMsg = ""
    }


init =
    ( initModel, Cmd.none )


view model =
    Html.div []
        [
         Html.button [ Html.Events.onClick (UI (CreateCustomer newCustomer)) ] [ Html.text "Create User" ]
        , viewDbMsg model
        , viewCustomers model.all
        ]

viewDbMsg model =
    Html.div [] [ Html.text "Last DB Message ", Html.text model.dbMsg ]


viewCustomers list =
    Html.ul []
        (List.map
            (\customer ->
                Html.li []
                    [ Html.text customer.name
                    , Html.text customer.birthday
                    , Html.text customer.company
                    , Html.button [ Html.Events.onClick (UI (DeleteCustomer (encodedCustomer customer))) ] [ Html.text "Delete" ]
                    ]
            )
            list
        )

encodedCustomer: FirebaseCustomer -> Value
encodedCustomer customer =
    Encode.string customer.id

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
        UI CustomerList ->
            ( model, toFirebaseDB ( "Database/Customer/List", Nothing ) )

        UI (CreateCustomer valueObject) ->
            ( model, toFirebaseDB ( "Database/Customer/Create", Just valueObject ) )
        UI (DeleteCustomer customerId) ->
            ( model, toFirebaseDB ( "Database/Customer/Delete", Just customerId ) )



subscriptions _ =
    fromFirebaseDB (decodeFirebaseDBValue)


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

