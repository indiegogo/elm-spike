port module Firebase.DB exposing
        ( main
        , initModel
        , update
        , view
        , subscriptions
        , Msg(UI)
        , FirebaseMsg(CustomerList)
        , FirebaseCustomer
        , Model
        , sanitizeId
        , sanitizeList
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

import Http
-- elm-package install -- yes noredink/elm-decode-pipeline

import Json.Decode.Pipeline
import RandomUser

port toFirebaseDB : ( String, Maybe Value ) -> Cmd msg

port fromFirebaseDB : (Value -> msg) -> Sub msg


type FirebaseMsg
    = CreateCustomer Value
    | CustomerList
    | DeleteCustomer Value
    | FetchRandomCustomers


type Msg
    =  FirebaseCustomerList (List FirebaseCustomer)
    | FirebaseErrorMessage String
    | UI FirebaseMsg
    | RandomUsersMeResponse (Result Http.Error RandomUser.RandomUserMe)




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

init: (Model, Cmd Msg)
init =
    ( initModel, Cmd.none )

view: Model -> Html.Html Msg
view model =
    Html.div []
        [
         Html.button [ Html.Events.onClick (UI FetchRandomCustomers) ] [ Html.text "Import Customers from RandomUser.me" ]
        ,Html.button [ Html.Events.onClick (UI (CreateCustomer newCustomer)) ] [ Html.text "Create Customer" ]
        , viewDbMsg model
        , viewCustomers model.all
        ]

viewDbMsg: Model -> Html.Html Msg
viewDbMsg model =
    Html.div [] [ Html.text "Last DB Message ", Html.text model.dbMsg ]

viewCustomers: List (FirebaseCustomer) -> Html.Html Msg
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
newCustomer: Value
newCustomer =
    Encode.object
        [ ( "name", Encode.string "Detective Sam Spade" )
        , ( "birthday", Encode.string "11/02/1979" )
        , ( "company", Encode.string "Syntax Sugar Inc." )
        ]



-- https://staltz.com/unidirectional-user-interface-architectures.html


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomUsersMeResponse randomUserMe ->
            let
                a = Debug.log "Random User Me Response" randomUserMe
                firebaseCustomerList  randomUser =
                    encodeFirebaseCustomerList <| randomUserMeToCustomers randomUser
            in
            case randomUserMe of
                Ok randomUser ->
                    let
                      b = Debug.log "firebaseCustomerList" (firebaseCustomerList randomUser)
                    in
                    (model, toFirebaseDB ("Database/Import/Customers", Just <| firebaseCustomerList randomUser) )
                Err httpError ->
                    case httpError of
                        Http.BadUrl a ->
                            ( { model | dbMsg = a}, Cmd.none )
                        Http.Timeout ->
                            ( { model | dbMsg = "Timeout"}, Cmd.none )
                        Http.NetworkError ->
                            ( { model | dbMsg = "NetworkError"}, Cmd.none )
                        Http.BadStatus a ->
                            ( { model | dbMsg = (toString a)}, Cmd.none )
                        Http.BadPayload a b ->
                            ( { model | dbMsg = (a ++":"++(toString b))}, Cmd.none )

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
        UI (FetchRandomCustomers) ->
            (model, importFromRandomUserMe )


importFromRandomUserMe: Cmd Msg
importFromRandomUserMe =
    Http.send RandomUsersMeResponse (Http.get "https://randomuser.me/api/?results=5" RandomUser.decodeRandomUserMe)

randomUserMeToCustomers: RandomUser.RandomUserMe -> List (FirebaseCustomer)
randomUserMeToCustomers list =
    List.map
        (\randomUser ->  mapRandomUserToFirebaseCustomer randomUser )
         list.results

mapRandomUserToFirebaseCustomer: RandomUser.RandomUser -> FirebaseCustomer
mapRandomUserToFirebaseCustomer r=
    { birthday = r.dob
    , company = "Random User"
    , name    = List.foldr (++) "" <| List.map (\s -> toCapital s) [r.name.title, " ", r.name.first, " ", r.name.last]
    , id      = sanitizeId <| r.id.name ++ ( Maybe.withDefault "" <| r.id.value )
    , pictureUrl = r.picture.large
    }

-- id for firebase must not contain
-- ".", "#", "$", "/", "[", or "]"
sanitizeList : List (String)
sanitizeList=
    [".","#","$","/","[","]"]

sanitizeId: String -> String
sanitizeId idForFirebase =
    String.map
        (\char->
           case (List.member (String.fromChar char) sanitizeList) of
             True ->
                '-'
             _ ->
                 char
        )
        idForFirebase

-- https://github.com/rainteller/elm-capitalize/blob/master/Capitalize.elm
toCapital : String -> String
toCapital str =
    String.toUpper(String.left 1 str) ++ String.dropLeft 1 str

subscriptions: Model -> Sub Msg
subscriptions _ =
    fromFirebaseDB (decodeFirebaseDBValue)


decodeFirebaseDBValue: Value -> Msg
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
    {
      pictureUrl : String
    , birthday : String
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
        |> DecodePipeline.required "pictureUrl" (Decode.string)
        |> DecodePipeline.required "birthday" (Decode.string)
        |> DecodePipeline.required "company" (Decode.string)
        |> DecodePipeline.required "name" (Decode.string)
        |> DecodePipeline.required "id" (Decode.string)


encodeFirebaseCustomer : FirebaseCustomer -> Encode.Value
encodeFirebaseCustomer record =
    Encode.object
        [
          ( "pictureUrl", Encode.string <| record.pictureUrl )
        , ( "birthday", Encode.string <| record.birthday )
        , ( "company", Encode.string <| record.company )
        , ( "name", Encode.string <| record.name )
        , ( "id", Encode.string <| record.id )
        ]

encodeFirebaseCustomerList : List (FirebaseCustomer) -> Encode.Value
encodeFirebaseCustomerList customers =
    Encode.list <| List.map encodeFirebaseCustomer <| customers
