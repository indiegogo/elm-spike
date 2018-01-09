port module Firebase.DB
    exposing
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

import Style exposing (buttonStyle)
import Html
import Html.Attributes
import Html.Events
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline as DecodePipeline
import Models.Customer exposing (Customer, decodeCustomerList, encodeCustomerList)
import Http


-- elm-package install -- yes noredink/elm-decode-pipeline

import Json.Decode.Pipeline
import Utils.RandomUser as RandomUser
import Models.Customer as MCustomer
import Dict


port toFirebaseDB : ( String, Maybe Value ) -> Cmd msg


port fromFirebaseDB : (Value -> msg) -> Sub msg


type FirebaseMsg
    = CreateCustomer Value
    | CustomerList
    | DeleteCustomer String
    | FetchRandomCustomers


type Msg
    = SetCustomers MCustomer.CustomersById
    | FirebaseErrorMessage String
    | UI FirebaseMsg
    | RandomUsersMeResponse (Result Http.Error RandomUser.RandomUserMe)
    | UpdateImportAmount String


type alias Model =
    { dbMsg : String
    , customersById : MCustomer.CustomersById
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
    { customersById = MCustomer.emptyCustomersById
    , dbMsg = ""
    , importAmount = "10"
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


customerCount : Model -> Int
customerCount model =
    List.length (Dict.keys model.customersById)


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.text <| "Customers " ++ (toString <| customerCount model)
        , Html.input [ Html.Events.onInput UpdateImportAmount, Html.Attributes.value model.importAmount ] []
        , Html.button [ buttonStyle, Html.Events.onClick (UI FetchRandomCustomers) ] [ Html.text "Import Customers from RandomUser.me" ]
        , Html.button [ buttonStyle, Html.Events.onClick (UI (DeleteCustomer "")) ] [ Html.text "Delete All" ]
        , viewDbMsg model
        , viewCustomers <| Dict.values model.customersById
        ]


viewDbMsg : Model -> Html.Html Msg
viewDbMsg model =
    Html.div [] [ Html.text "Last DB Message ", Html.text model.dbMsg ]


viewCustomers : List Customer -> Html.Html Msg
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
                    , Html.button [ Html.Events.onClick (UI (DeleteCustomer customer.id)) ] [ Html.text "Delete" ]
                    ]
            )
            list
        )


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
                    encodeCustomerList <| RandomUser.randomUserMeToCustomers randomUser
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

        SetCustomers customersById ->
            ( { model | customersById = customersById }, Cmd.none )

        FirebaseErrorMessage lastUpdateMessage ->
            ( { model | dbMsg = lastUpdateMessage }, Cmd.none )

        UpdateImportAmount str ->
            ( { model | importAmount = str }, Cmd.none )

        UI CustomerList ->
            ( model, toFirebaseDB ( "Database/Customer/List", Nothing ) )

        UI (CreateCustomer valueObject) ->
            ( model, toFirebaseDB ( "Database/Customer/Create", Just valueObject ) )

        UI (DeleteCustomer customerId) ->
            ( model, toFirebaseDB ( "Database/Customer/Delete", Just (Encode.string customerId) ) )

        UI FetchRandomCustomers ->
            ( model, importFromRandomUserMe model )


importFromRandomUserMe : Model -> Cmd Msg
importFromRandomUserMe { importAmount } =
    RandomUser.importFromRandomUserMe RandomUsersMeResponse importAmount


subscriptions : Model -> Sub Msg
subscriptions _ =
    fromFirebaseDB decodeFirebaseDBValue


type alias FirebaseEvent =
    { event : String
    , value : Value
    }


decodeFirebaseEvent : Json.Decode.Decoder FirebaseEvent
decodeFirebaseEvent =
    Json.Decode.Pipeline.decode FirebaseEvent
        |> Json.Decode.Pipeline.required "event" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "value" (Json.Decode.value)


eventToMsg : Result String FirebaseEvent -> Msg
eventToMsg result =
    case result of
        Err string ->
            FirebaseErrorMessage ("EventMapping Error :" ++ string)

        Ok { event, value } ->
            case event of
                "customer_list" ->
                    let
                        result =
                            Decode.decodeValue decodeCustomerList value
                    in
                        case result of
                            Ok customerList ->
                                SetCustomers (MCustomer.customersByIdFromList customerList)

                            Err msg ->
                                FirebaseErrorMessage ("CustomerList Value Error :" ++ toString msg)

                _ ->
                    FirebaseErrorMessage ("Unknown event :" ++ event)


decodeFirebaseDBValue : Value -> Msg
decodeFirebaseDBValue v =
    (eventToMsg (Decode.decodeValue decodeFirebaseEvent v))
