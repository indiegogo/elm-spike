module Customers.DetailList exposing (..)

import Html exposing (Html, div, text, li, ol, button, img, h3)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, style, src)
import Http
import Models.Customer as Customer exposing (Customer, CustomerAddress, CustomerCreditCard, encodeCustomerList)
import Utils.RandomUser exposing (RandomUserMe, importFromRandomUserMeWithSeed, randomUserMeToCustomers)
import Window
import Task
import Debug as D
import Array


type alias Model =
      { customers : List Customer
      , errorMsg : String
      , currentCustomerIndex : Int
      , customersToShow : Int
      , cardWidth : Int
    }


type Actions
    = ImportCustomers (Result Http.Error RandomUserMe)
    | Resize Window.Size
    | Next
    | Previous


main : Program Never Model Actions
main =
    Html.program
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }


initModel : Model
initModel =
    (Model [] "" 0 3 400)


initCmd : Cmd Actions
initCmd =
    Cmd.batch
        [ importFromRandomUserMeWithSeed ImportCustomers "10" "abc123-seed"
        , Task.perform Resize Window.size
        ]


init : ( Model, Cmd Actions )
init =
    ( initModel
    , initCmd
    )


customerCardWidth : Model -> Int
customerCardWidth =
    .cardWidth


customerStyle : Html.Attribute Actions
customerStyle =
    style
        [ ( "width", (toString customerCardWidth) ++ "px" ) ]


view : Model -> Html Actions
view model =
    div [ class "customer-list" ]
        [ button [ onClick Previous ] [ text "Previous" ]
        , ol [] (customerList model)
        , button [ onClick Next ] [ text "Next" ]
        ]
info: Customer -> List(Html Actions)
info customer =
    [ div [ class "businessCard__line", class "businessCard--name" ] [ text customer.fullname ]
    , div [ class "businessCard__line", class "businessCard--title" ] [ text customer.title ]
    , div [ class "businessCard__line", class "businessCard--company" ] [ text customer.company ]
    , div [ class "businessCard__line", class "businessCard--phone" ] [ text customer.company ]
    , div [ class "businessCard__line", class "businessCard--email" ] [ text customer.birthday ]
    ]
 
customerToHtml : Customer -> Html Actions
customerToHtml customer =
    li [ customerStyle, class "customer", class ("id-" ++ customer.id) ]
        [ div [ class "businessCard" ]
            [ img [ src customer.pictureUrl, class "picture" ] []
            , div [ class "bigLineHeight", class "businessCard__info" ] (info customer)
            ]
        , div [ class "customer__detail" ]
            [ viewCustomerAddress "Delivery Address" customer.deliveryAddress
            , viewCustomerAddress "Billing Address" customer.billingAddress
            , viewCustomerCreditCard customer.creditCard
            ]
        ]


viewCustomerCreditCard : CustomerCreditCard -> Html msg
viewCustomerCreditCard creditCard =
    div []
        [ div [ class "number" ] [ text creditCard.number ]
        , div [ class "expDate" ] [ text creditCard.expDate ]
        , div [ class "csv" ] [ text creditCard.csv ]
        ]


viewCustomerAddress : String -> CustomerAddress -> Html msg
viewCustomerAddress label address =
    div [] [
         h3 [] [text label]
    ,div [class "bigLineHeight"]
        [ div [class "businessCard__line", class "street" ] [ text address.street ]
        , div [class "businessCard__line", class "city" ] [ text address.city ]
        , div [class "businessCard__line", class "state" ] [ text address.state ]
        , div [class "businessCard__line", class "postcode" ] [ text address.postcode ]
        , div [class "businessCard__line", class "country" ] [ text address.country ]
        ]
        ]

customerList : Model -> List (Html Actions)
customerList { customers, customersToShow, currentCustomerIndex } =
    List.map customerToHtml <|
        customerWindow
            { customers = customers
            , customersToShow = customersToShow
            , currentCustomerIndex = currentCustomerIndex
            }


subscriptions : Model -> Sub Actions
subscriptions model =
    Window.resizes (\size -> Resize size)

{-
-- this will divide by zero when it is defined
unsafeFun =
    let
        start = 0
        end   = 3
        len   = List.length []
    in
        List.range start end |> List.map (\idx -> idx % len)
-}

customerWindow :
    { customers : List Customer
    , customersToShow : Int
    , currentCustomerIndex : Int
    }
    -> List Customer
customerWindow { customers, customersToShow, currentCustomerIndex } =
    let
        array = D.log "array" <|
            Array.fromList customers

        len = D.log "len" <|
            List.length customers

        start = D.log "start" <|
            currentCustomerIndex

        end = D.log "end" <|
            currentCustomerIndex + customersToShow

        indexes =
            case len of
                0 ->
                    List.range start end
                _ ->
                    List.range start end |> List.map (\idx -> idx % len)
 
        lookup_customer_index indexPosition = D.log "lookup" (
            Array.get indexPosition (Array.fromList indexes) |> Maybe.withDefault 0
                                                             )
        lookup_customer customerPosition =
            Maybe.withDefault Customer.emptyModel
                (Array.get
                    (lookup_customer_index customerPosition)
                    array
                )

        lookup =
            (\idx -> lookup_customer idx)
    in
        Array.initialize len lookup
            |> Array.toList
            |> List.take customersToShow


calcCustomersToShow : Model -> Window.Size -> Int
calcCustomersToShow model { height, width } =
    width // customerCardWidth model


nextCustomerIndex : Model -> Int
nextCustomerIndex { currentCustomerIndex, customers } =
    (currentCustomerIndex + 1) % (List.length customers)


prevCustomerIndex : Model -> Int
prevCustomerIndex { currentCustomerIndex, customers } =
    (currentCustomerIndex - 1) % (List.length customers)


update : Actions -> Model -> ( Model, Cmd Actions )
update msg model =
    case msg of
        Next ->
            ( { model | currentCustomerIndex = nextCustomerIndex model }, Cmd.none )

        Previous ->
            ( { model | currentCustomerIndex = prevCustomerIndex model }, Cmd.none )

        Resize windowSize ->
            ( { model | customersToShow = calcCustomersToShow model windowSize }, Cmd.none )

        ImportCustomers result ->
            case result of
                Ok randomUserMe ->
                    let
                        customerList =
                            randomUserMeToCustomers randomUserMe
                    in
                        ( { model | customers = customerList }, Cmd.none )

                Err httpError ->
                    case httpError of
                        Http.BadUrl a ->
                            ( { model | errorMsg = a }, Cmd.none )

                        Http.Timeout ->
                            ( { model | errorMsg = "Timeout" }, Cmd.none )

                        Http.NetworkError ->
                            ( { model | errorMsg = "NetworkError" }, Cmd.none )

                        Http.BadStatus a ->
                            ( { model | errorMsg = toString a }, Cmd.none )

                        Http.BadPayload a b ->
                            ( { model | errorMsg = a ++ ":" ++ toString b }, Cmd.none )
