module Views.Customer exposing (..)

import Models.Customer exposing (Customer, CustomerAddress, CustomerCreditCard)
import Html exposing (Html, div, text, li, ol, button, img, h3, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, style, src, value)


type CustomerEvent
    = Fullname String
    | Phone String
    | Title String
    | Company String
    | Birthday String


type AddressEvent
    = Street String
    | City String
    | State String
    | PostCode String
    | Country String


type CreditCardEvent
    = Number String
    | ExpDate String
    | Csv String


type EditEvent
    = CustomerEdit CustomerEvent
    | CreditCardEdit CreditCardEvent
    | BillingAddressEdit AddressEvent
    | DeliveryAddressEdit AddressEvent


type Msg
    = Edit Customer
    | Show Customer
    | Save Customer
    | Update EditEvent


type alias CustomerEvents =
    { fullname : Html.Attribute Msg
    , phone : Html.Attribute Msg
    , title : Html.Attribute Msg
    , company : Html.Attribute Msg
    , birthday : Html.Attribute Msg
    }


type alias CustomerAddressEvents =
    { street : Html.Attribute Msg
    , city : Html.Attribute Msg
    , state : Html.Attribute Msg
    , postcode : Html.Attribute Msg
    , country : Html.Attribute Msg
    }


type alias CustomerCreditCardEvents =
    { number : Html.Attribute Msg
    , expDate : Html.Attribute Msg
    , csv : Html.Attribute Msg
    }


update : EditEvent -> Maybe Customer -> Maybe Customer
update msg maybeModel =
    case maybeModel of
        Nothing ->
            Nothing

        Just model ->
            case msg of
                CreditCardEdit evt ->
                    let
                        creditCard =
                            model.creditCard
                    in
                        case evt of
                            Csv str ->
                                Just { model | creditCard = { creditCard | csv = str } }

                            Number str ->
                                Just { model | creditCard = { creditCard | number = str } }

                            ExpDate str ->
                                Just { model | creditCard = { creditCard | expDate = str } }

                BillingAddressEdit evt ->
                    let
                        address =
                            model.billingAddress
                    in
                        case evt of
                            Street str ->
                                Just { model | billingAddress = { address | street = str } }

                            City str ->
                                Just { model | billingAddress = { address | city = str } }

                            State str ->
                                Just { model | billingAddress = { address | state = str } }

                            PostCode str ->
                                Just { model | billingAddress = { address | postcode = str } }

                            Country str ->
                                Just { model | billingAddress = { address | country = str } }

                DeliveryAddressEdit evt ->
                    let
                        address =
                            model.deliveryAddress
                    in
                        case evt of
                            Street str ->
                                Just { model | deliveryAddress = { address | street = str } }

                            City str ->
                                Just { model | deliveryAddress = { address | city = str } }

                            State str ->
                                Just { model | deliveryAddress = { address | state = str } }

                            PostCode str ->
                                Just { model | deliveryAddress = { address | postcode = str } }

                            Country str ->
                                Just { model | deliveryAddress = { address | country = str } }

                CustomerEdit evt ->
                    case evt of
                        Fullname str ->
                            Just { model | fullname = str }

                        Phone str ->
                            Just { model | phone = str }

                        Title str ->
                            Just { model | title = str }

                        Birthday str ->
                            Just { model | birthday = str }

                        Company str ->
                            Just { model | company = str }


customerCreditCardEvent : CustomerCreditCardEvents
customerCreditCardEvent =
    { number = (Html.Attributes.map Update (Html.Attributes.map CreditCardEdit (onInput Number)))
    , expDate = (Html.Attributes.map Update (Html.Attributes.map CreditCardEdit (onInput ExpDate)))
    , csv = (Html.Attributes.map Update (Html.Attributes.map CreditCardEdit (onInput Csv)))
    }


customerBillingAddressEvent : CustomerAddressEvents
customerBillingAddressEvent =
    { street = (Html.Attributes.map Update (Html.Attributes.map BillingAddressEdit (onInput Street)))
    , city = (Html.Attributes.map Update (Html.Attributes.map BillingAddressEdit (onInput City)))
    , state = (Html.Attributes.map Update (Html.Attributes.map BillingAddressEdit (onInput State)))
    , postcode = (Html.Attributes.map Update (Html.Attributes.map BillingAddressEdit (onInput PostCode)))
    , country = (Html.Attributes.map Update (Html.Attributes.map BillingAddressEdit (onInput Country)))
    }


customerDeliveryAddressEvent : CustomerAddressEvents
customerDeliveryAddressEvent =
    { street = (Html.Attributes.map Update (Html.Attributes.map DeliveryAddressEdit (onInput Street)))
    , city = (Html.Attributes.map Update (Html.Attributes.map DeliveryAddressEdit (onInput City)))
    , state = (Html.Attributes.map Update (Html.Attributes.map DeliveryAddressEdit (onInput State)))
    , postcode = (Html.Attributes.map Update (Html.Attributes.map DeliveryAddressEdit (onInput PostCode)))
    , country = (Html.Attributes.map Update (Html.Attributes.map DeliveryAddressEdit (onInput Country)))
    }


customerEvents : CustomerEvents
customerEvents =
    { fullname = (Html.Attributes.map Update (Html.Attributes.map CustomerEdit (onInput Fullname)))
    , phone = (Html.Attributes.map Update (Html.Attributes.map CustomerEdit (onInput Phone)))
    , title = (Html.Attributes.map Update (Html.Attributes.map CustomerEdit (onInput Title)))
    , company = (Html.Attributes.map Update (Html.Attributes.map CustomerEdit (onInput Company)))
    , birthday = (Html.Attributes.map Update (Html.Attributes.map CustomerEdit (onInput Birthday)))
    }


type alias HtmlFunction =
    List (Html.Attribute Msg) -> List (Html.Html Msg) -> Html Msg


type alias InputMapperFunction a b =
    List (Html.Attribute Msg) -> (a -> String) -> (b -> Html.Attribute Msg) -> Html Msg


editInfo : Customer -> List (Html Msg)
editInfo customer =
    info (modelEditInputMapper customer customerEvents)


showInfo : Customer -> List (Html Msg)
showInfo customer =
    info (modelShowInputMapper customer customerEvents)


modelShowInputMapper : a -> b -> InputMapperFunction a b
modelShowInputMapper model events attrs dataAccessFunc eventFunc =
    div attrs [ text (dataAccessFunc model) ]


modelEditInputMapper : a -> b -> InputMapperFunction a b
modelEditInputMapper model events attrs dataAccessFunc eventFunc =
    input (attrs ++ [ value (dataAccessFunc model), eventFunc events ]) []


info : InputMapperFunction Customer CustomerEvents -> List (Html Msg)
info htmlFunc =
    [ htmlFunc [ class "businessCard__line", class "businessCard--name" ] .fullname .fullname
    , htmlFunc [ class "businessCard__line", class "businessCard--title" ] .title .title
    , htmlFunc [ class "businessCard__line", class "businessCard--company" ] .company .company
    , htmlFunc [ class "businessCard__line", class "businessCard--phone" ] .phone .phone
    , htmlFunc [ class "businessCard__line", class "businessCard--email" ] .birthday .birthday
    ]


showView : Customer -> Html Msg
showView customer =
    li [ class "customer", class ("id-" ++ customer.id) ]
        [ div [ onClick (Edit customer), class "material-icons" ] [ text "edit" ]
        , div [ class "businessCard" ]
            [ img [ src customer.pictureUrl, class "picture" ] []
            , div [ class "bigLineHeight", class "businessCard__info" ] (showInfo customer)
            ]
        , div [ class "customer__detail" ]
            [ showCustomerAddress "Delivery Address" customer.deliveryAddress customerDeliveryAddressEvent
            , showCustomerCreditCard customer.creditCard customerCreditCardEvent
            , showCustomerAddress "Billing Address" customer.billingAddress customerBillingAddressEvent
            ]
        ]


editView : Customer -> Html Msg
editView customer =
    li [ class "customer", class ("id-" ++ customer.id) ]
        [ div [ onClick (Show customer), class "material-icons" ] [ text "cancel" ]
        , div [ onClick (Save customer), class "material-icons" ] [ text "save" ]
        , div [ class "businessCard" ]
            [ img [ src customer.pictureUrl, class "picture" ] []
            , div [ class "bigLineHeight", class "businessCard__info" ] (editInfo customer)
            ]
        , div [ class "customer__detail" ]
            [ editCustomerAddress "Delivery Address" customer.deliveryAddress customerDeliveryAddressEvent
            , editCustomerCreditCard customer.creditCard customerCreditCardEvent
            , editCustomerAddress "Billing Address" customer.billingAddress customerBillingAddressEvent
            ]
        ]


showCustomerCreditCard : CustomerCreditCard -> CustomerCreditCardEvents -> Html Msg
showCustomerCreditCard customerCard customerAddressEvents =
    viewCustomerCreditCard (modelShowInputMapper customerCard customerAddressEvents)


editCustomerCreditCard : CustomerCreditCard -> CustomerCreditCardEvents -> Html Msg
editCustomerCreditCard customerCard customerAddressEvents =
    viewCustomerCreditCard (modelEditInputMapper customerCard customerAddressEvents)


viewCustomerCreditCard : InputMapperFunction CustomerCreditCard CustomerCreditCardEvents -> Html Msg
viewCustomerCreditCard htmlFunc =
    div []
        [ h3 [] [ text "Billing Information" ]
        , div [ class "bigLineHeight" ]
            [ htmlFunc [ class "number" ] .number .number
            , htmlFunc [ class "expDate" ] .expDate .expDate
            , htmlFunc [ class "csv" ] .csv .csv
            ]
        ]


showCustomerAddress : String -> CustomerAddress -> CustomerAddressEvents -> Html Msg
showCustomerAddress label address addressEvents =
    viewCustomerAddress (modelShowInputMapper address addressEvents) label


editCustomerAddress : String -> CustomerAddress -> CustomerAddressEvents -> Html Msg
editCustomerAddress label address addressEvents =
    viewCustomerAddress (modelEditInputMapper address addressEvents) label


viewCustomerAddress : InputMapperFunction CustomerAddress CustomerAddressEvents -> String -> Html Msg
viewCustomerAddress htmlFunc label =
    div []
        [ h3 [] [ text label ]
        , div [ class "bigLineHeight" ]
            [ htmlFunc [ class "businessCard__line", class "street" ] .street .street
            , htmlFunc [ class "businessCard__line", class "city" ] .city .city
            , htmlFunc [ class "businessCard__line", class "state" ] .state .state
            , htmlFunc [ class "businessCard__line", class "postcode" ] .postcode .postcode
            , htmlFunc [ class "businessCard__line", class "country" ] .country .country
            ]
        ]
