port module Firebase.DB
    exposing
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

import Style exposing (buttonStyle)
import Html
import Html.Attributes
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
    = FirebaseCustomerList (List FirebaseCustomer)
    | FirebaseErrorMessage String
    | UI FirebaseMsg
    | RandomUsersMeResponse (Result Http.Error RandomUser.RandomUserMe)
    | UpdateImportAmount String


type alias Model =
    { dbMsg : String
    , all : List FirebaseCustomer
    , importAmount : String
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { all = []
    , dbMsg = ""
    , importAmount = "10"
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.text <| "Customers " ++ (toString <| List.length model.all)
        , Html.input [ Html.Events.onInput UpdateImportAmount, Html.Attributes.value model.importAmount ] []
        , Html.button [ buttonStyle, Html.Events.onClick (UI FetchRandomCustomers) ] [ Html.text "Import Customers from RandomUser.me" ]
        , viewDbMsg model
        , viewCustomers model.all
        ]


viewDbMsg : Model -> Html.Html Msg
viewDbMsg model =
    Html.div [] [ Html.text "Last DB Message ", Html.text model.dbMsg ]


viewCustomers : List FirebaseCustomer -> Html.Html Msg
viewCustomers list =
    Html.ul []
        (List.map
            (\customer ->
                Html.li []
                    [ Html.text (" ID " ++ customer.id)
                    , Html.text customer.fullname
                    , Html.text customer.birthday
                    , Html.text customer.company
                    , Html.text customer.email
                    , Html.button [ Html.Events.onClick (UI (DeleteCustomer (encodedCustomer customer))) ] [ Html.text "Delete" ]
                    ]
            )
            list
        )


encodedCustomer : FirebaseCustomer -> Value
encodedCustomer customer =
    Encode.string customer.id


cupcakeImg =
    "https://2.bp.blogspot.com/-CAtiru0_Wgk/V7PgKQQ3e1I/AAAAAAAF85Y/KI-9G5903Gg7y_Wog47Ogib3f-Gc22kWwCLcB/s1600/cupcake-778704_960_720.png"



-- https://staltz.com/unidirectional-user-interface-architectures.html


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomUsersMeResponse randomUserMe ->
            let
                a =
                    Debug.log "Random User Me Response" randomUserMe

                firebaseCustomerList randomUser =
                    encodeFirebaseCustomerList <| randomUserMeToCustomers randomUser
            in
                case randomUserMe of
                    Ok randomUser ->
                        let
                            b =
                                Debug.log "firebaseCustomerList" (firebaseCustomerList randomUser)
                        in
                            ( model, toFirebaseDB ( "Database/Import/Customers", Just <| firebaseCustomerList randomUser ) )

                    Err httpError ->
                        case httpError of
                            Http.BadUrl a ->
                                ( { model | dbMsg = a }, Cmd.none )

                            Http.Timeout ->
                                ( { model | dbMsg = "Timeout" }, Cmd.none )

                            Http.NetworkError ->
                                ( { model | dbMsg = "NetworkError" }, Cmd.none )

                            Http.BadStatus a ->
                                ( { model | dbMsg = toString a }, Cmd.none )

                            Http.BadPayload a b ->
                                ( { model | dbMsg = a ++ ":" ++ toString b }, Cmd.none )

        FirebaseCustomerList all ->
            ( { model | all = all }, Cmd.none )

        FirebaseErrorMessage lastUpdateMessage ->
            ( { model | dbMsg = lastUpdateMessage }, Cmd.none )

        UpdateImportAmount str ->
            ( { model | importAmount = str }, Cmd.none )

        UI CustomerList ->
            ( model, toFirebaseDB ( "Database/Customer/List", Nothing ) )

        UI (CreateCustomer valueObject) ->
            ( model, toFirebaseDB ( "Database/Customer/Create", Just valueObject ) )

        UI (DeleteCustomer customerId) ->
            ( model, toFirebaseDB ( "Database/Customer/Delete", Just customerId ) )

        UI FetchRandomCustomers ->
            ( model, importFromRandomUserMe model )


importFromRandomUserMe : Model -> Cmd Msg
importFromRandomUserMe { importAmount } =
    Http.send RandomUsersMeResponse (Http.get ("https://randomuser.me/api/?results=" ++ importAmount) RandomUser.decodeRandomUserMe)


randomUserMeToCustomers : RandomUser.RandomUserMe -> List FirebaseCustomer
randomUserMeToCustomers list =
    List.map
        (\randomUser -> mapRandomUserToFirebaseCustomer randomUser)
        list.results


mapRandomUserToFirebaseCustomer : RandomUser.RandomUser -> FirebaseCustomer
mapRandomUserToFirebaseCustomer r =
    let
        a =
            Debug.log "randomUser" r
    in
        { email = r.email
        , fullname = List.foldr (++) "" <| List.map (\s -> toCapital s) [ r.name.title, " ", r.name.first, " ", r.name.last ]
        , phone = r.phone
        , birthday = r.dob
        , company = "Random User"
        , id = sanitizeId <| r.id.name ++ (Maybe.withDefault "" <| r.id.value)
        , pictureUrl = r.picture.large
        , title = ""
        , deliveryAddress =
            { street = r.location.street
            , city = r.location.city
            , state = r.location.state
            , postcode = toString r.location.postcode
            , country = ""
            }
        , billingAddress =
            { street = r.location.street
            , city = r.location.city
            , state = r.location.state
            , postcode = toString r.location.postcode
            , country = ""
            }
        , creditCard =
            { number = ""
            , expDate = ""
            , csv = ""
            }
        }



-- id for firebase must not contain
-- ".", "#", "$", "/", "[", or "]"


sanitizeList : List String
sanitizeList =
    [ ".", "#", "$", "/", "[", "]" ]


sanitizeId : String -> String
sanitizeId idForFirebase =
    String.map
        (\char ->
            case List.member (String.fromChar char) sanitizeList of
                True ->
                    '-'

                _ ->
                    char
        )
        idForFirebase



-- https://github.com/rainteller/elm-capitalize/blob/master/Capitalize.elm


toCapital : String -> String
toCapital str =
    String.toUpper (String.left 1 str) ++ String.dropLeft 1 str


subscriptions : Model -> Sub Msg
subscriptions _ =
    fromFirebaseDB decodeFirebaseDBValue


decodeFirebaseDBValue : Value -> Msg
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
                FirebaseErrorMessage ("Unknown Error :" ++ toString msg)


type alias FirebaseCustomer =
    { pictureUrl : String
    , birthday : String
    , company : String
    , fullname : String
    , phone : String
    , email : String
    , title : String
    , id : String
    , deliveryAddress : CustomerAddress
    , billingAddress : CustomerAddress
    , creditCard : CustomerCreditCard
    }


type alias CustomerCreditCard =
    { number : String
    , expDate : String
    , csv : String
    }


type alias CustomerAddress =
    { street : String
    , city : String
    , state : String
    , postcode : String
    , country : String
    }


decodeFirebaseCustomerList : Decode.Decoder (List FirebaseCustomer)
decodeFirebaseCustomerList =
    Decode.list decodeFirebaseCustomer



--
-- BUG WARNING
-- Note: The order of the decoder fields
--       must correspond to the order for fields of the type alias
--


decodeFirebaseCustomer : Decode.Decoder FirebaseCustomer
decodeFirebaseCustomer =
    DecodePipeline.decode FirebaseCustomer
        |> DecodePipeline.required "pictureUrl" Decode.string
        |> DecodePipeline.required "birthday" Decode.string
        |> DecodePipeline.required "company" Decode.string
        |> DecodePipeline.required "fullname" Decode.string
        |> DecodePipeline.required "phone" Decode.string
        |> DecodePipeline.required "email" Decode.string
        |> DecodePipeline.required "title" Decode.string
        |> DecodePipeline.required "id" Decode.string
        |> DecodePipeline.required "deliveryAddress" decodeCustomerAddress
        |> DecodePipeline.required "billingAddress" decodeCustomerAddress
        |> DecodePipeline.required "creditCard" decodeCustomerCreditCard


decodeCustomerCreditCard : Decode.Decoder CustomerCreditCard
decodeCustomerCreditCard =
    DecodePipeline.decode CustomerCreditCard
        |> DecodePipeline.required "number" Decode.string
        |> DecodePipeline.required "expDate" Decode.string
        |> DecodePipeline.required "csv" Decode.string


decodeCustomerAddress : Decode.Decoder CustomerAddress
decodeCustomerAddress =
    DecodePipeline.decode CustomerAddress
        |> DecodePipeline.required "street" Decode.string
        |> DecodePipeline.required "city" Decode.string
        |> DecodePipeline.required "state" Decode.string
        |> DecodePipeline.required "postcode" Decode.string
        |> DecodePipeline.required "country" Decode.string


encodeCustomerCreditCard : CustomerCreditCard -> Encode.Value
encodeCustomerCreditCard record =
    Encode.object
        [ ( "number", Encode.string <| record.number )
        , ( "expDate", Encode.string <| record.expDate )
        , ( "csv", Encode.string <| record.csv )
        ]


encodeCustomerAddress : CustomerAddress -> Encode.Value
encodeCustomerAddress record =
    Encode.object
        [ ( "street", Encode.string <| record.street )
        , ( "city", Encode.string <| record.city )
        , ( "state", Encode.string <| record.state )
        , ( "postcode", Encode.string <| record.postcode )
        , ( "country", Encode.string <| record.country )
        ]


encodeFirebaseCustomer : FirebaseCustomer -> Encode.Value
encodeFirebaseCustomer record =
    Encode.object
        [ ( "pictureUrl", Encode.string <| record.pictureUrl )
        , ( "birthday", Encode.string <| record.birthday )
        , ( "company", Encode.string <| record.company )
        , ( "fullname", Encode.string <| record.fullname )
        , ( "phone", Encode.string <| record.phone )
        , ( "email", Encode.string <| record.email )
        , ( "title", Encode.string <| record.title )
        , ( "id", Encode.string <| record.id )
        , ( "creditCard", encodeCustomerCreditCard <| record.creditCard )
        , ( "deliveryAddress", encodeCustomerAddress <| record.deliveryAddress )
        , ( "billingAddress", encodeCustomerAddress <| record.billingAddress )
        ]


encodeFirebaseCustomerList : List FirebaseCustomer -> Encode.Value
encodeFirebaseCustomerList customers =
    Encode.list <| List.map encodeFirebaseCustomer <| customers
