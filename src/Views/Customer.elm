module Views.Customer exposing (..)

import Models.Customer exposing (Customer, CustomerAddress, CustomerCreditCard)
import Html exposing (Html, div, text, li, ol, button, img, h3, input, label)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, style, src, value)
import Validate exposing (ifBlank, ifNotInt, Validator)
import Dict


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
    | NoOp String



-- used to work around dict maybe


type Msg
    = Edit Customer
    | Show Customer
    | Save Customer
    | Update EditEvent


update : EditEvent -> Maybe Customer -> Maybe Customer
update msg maybeModel =
    case maybeModel of
        Nothing ->
            Nothing

        Just model ->
            case msg of
                NoOp v ->
                    maybeModel

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


type alias FieldEntry =
    ( Html.Attribute Msg
    , List (Validator String String)
    , -- this function declaration is the weak part of my design
      -- as it hinges on the fact that input fields operate on
      --- String values and so the model field types are all strings
      Customer -> String
    )


type alias EventDict =
    Dict.Dict String FieldEntry



-- pair generate shorthand


(=>) =
    (,)


routeToUpdateInput : (msg -> EditEvent) -> (String -> msg) -> Html.Attribute Msg
routeToUpdateInput editEvent msg =
    (Html.Attributes.map Update (Html.Attributes.map editEvent (onInput msg)))


customerCreditCardEvents : EventDict
customerCreditCardEvents =
    Dict.fromList
        [ "number"
            => ( routeToUpdateInput CreditCardEdit Number
               , [ ifNotInt "Must Be Number", cannotBeBlank ]
               , .creditCard >> .number
               )
        , "expDate"
            => ( routeToUpdateInput CreditCardEdit ExpDate
               , [ cannotBeBlank ]
               , .creditCard >> .expDate
               )
        , "csv"
            => ( routeToUpdateInput CreditCardEdit Csv
               , [ ifNotInt "Must be Number", cannotBeBlank ]
               , .creditCard >> .csv
               )
        ]


customerBillingAddressEvents : EventDict
customerBillingAddressEvents =
    Dict.fromList
        [ "street"
            => ( routeToUpdateInput BillingAddressEdit Street
               , [ cannotBeBlank ]
               , .deliveryAddress >> .street
               )
        , "city"
            => ( routeToUpdateInput BillingAddressEdit City
               , [ cannotBeBlank ]
               , .deliveryAddress >> .city
               )
        , "state"
            => ( routeToUpdateInput BillingAddressEdit State
               , [ cannotBeBlank ]
               , .deliveryAddress >> .state
               )
        , "postcode"
            => ( routeToUpdateInput BillingAddressEdit PostCode
               , [ cannotBeBlank ]
               , .deliveryAddress >> .postcode
               )
        , "country"
            => ( routeToUpdateInput BillingAddressEdit Country
               , [ cannotBeBlank ]
               , .deliveryAddress >> .country
               )
        ]


customerDeliveryAddressEvents : EventDict
customerDeliveryAddressEvents =
    Dict.fromList
        [ "street"
            => ( routeToUpdateInput DeliveryAddressEdit Street
               , [ cannotBeBlank ]
               , .deliveryAddress >> .street
               )
        , "city"
            => ( routeToUpdateInput DeliveryAddressEdit City
               , [ cannotBeBlank ]
               , .deliveryAddress >> .city
               )
        , "state"
            => ( routeToUpdateInput DeliveryAddressEdit State
               , [ cannotBeBlank ]
               , .deliveryAddress >> .state
               )
        , "postcode"
            => ( routeToUpdateInput DeliveryAddressEdit PostCode
               , [ cannotBeBlank ]
               , .deliveryAddress >> .postcode
               )
        , "country"
            => ( routeToUpdateInput DeliveryAddressEdit Country
               , [ cannotBeBlank ]
               , .deliveryAddress >> .country
               )
        ]


customerEvents : EventDict
customerEvents =
    Dict.fromList
        [ "fullname"
            => ( routeToUpdateInput CustomerEdit Fullname
               , [ cannotBeBlank ]
               , .fullname
               )
        , "phone"
            => ( routeToUpdateInput CustomerEdit Phone
               , [ cannotBeBlank ]
               , .phone
               )
        , "title"
            => ( routeToUpdateInput CustomerEdit Title
               , [ cannotBeBlank ]
               , .title
               )
        , "company"
            => ( routeToUpdateInput CustomerEdit Company
               , [ cannotBeBlank ]
               , .company
               )
        , "birthday"
            => ( routeToUpdateInput CustomerEdit Birthday
               , [ cannotBeBlank ]
               , .birthday
               )
        ]

noOp =
    (Html.Attributes.map Update (onInput NoOp))


cannotBeBlank : Validator String String
cannotBeBlank =
    ifBlank "Cannot Be Blank"


type alias HtmlFunction =
    List (Html.Attribute Msg) -> List (Html.Html Msg) -> Html Msg


type alias InputMapperFunction =
    List (Html.Attribute Msg) -> String -> Html Msg


editInfo : Customer -> List (Html Msg)
editInfo customer =
    info (modelEditInputMapper customer customerEvents)


showInfo : Customer -> List (Html Msg)
showInfo customer =
    info (modelShowInputMapper customer customerEvents)


modelShowInputMapper : Customer -> EventDict -> InputMapperFunction
modelShowInputMapper model events attrs eventKey =
    let
        ( _, _, dataAccessFunc ) =
            lookupEvent eventKey events
    in
        div attrs [ text (dataAccessFunc model) ]


defaultNonOperationFieldEntry : String -> FieldEntry
defaultNonOperationFieldEntry key =
    ( noOp, [ cannotBeBlank ], (\_ -> "bad key used in form event spec: " ++ key) )


lookupEvent : String -> EventDict -> FieldEntry
lookupEvent key dict =
    Dict.get key dict |> Maybe.withDefault (defaultNonOperationFieldEntry key)


modelEditInputMapper : Customer -> EventDict -> InputMapperFunction
modelEditInputMapper model events attrs eventKey =
    let
        ( eventHandler, validations, dataAccessFunc ) =
            lookupEvent eventKey events

        fieldValue =
            dataAccessFunc model

        validClass =
            if Validate.any validations fieldValue then
                ""
            else
                "invalid"
    in
        div []
            [ label [ style [ ( "display", "none" ) ] ] [ text (toString (Validate.all validations fieldValue)) ]
            , input (attrs ++ [ value fieldValue, eventHandler, class validClass ]) []
            ]


info : InputMapperFunction -> List (Html Msg)
info htmlFunc =
    [ htmlFunc [ class "businessCard__line", class "businessCard--name" ] "fullname"
    , htmlFunc [ class "businessCard__line", class "businessCard--title" ] "title"
    , htmlFunc [ class "businessCard__line", class "businessCard--company" ] "company"
    , htmlFunc [ class "businessCard__line", class "businessCard--phone" ] "phone"
    , htmlFunc [ class "businessCard__line", class "businessCard--email" ] "birthday"
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
            [ showCustomerAddress "Delivery Address" customer customerDeliveryAddressEvents
            , showCustomerCreditCard customer customerCreditCardEvents
            , showCustomerAddress "Billing Address" customer customerBillingAddressEvents
            ]
        ]


validateCustomer : Customer -> Bool
validateCustomer customer =
    let
        convertDictToValidation dict =
            Dict.values dict
                |> List.map
                    (\( _, validations, dataAccessFunc ) ->
                        Validate.any validations (dataAccessFunc customer)
                    )

        validationList =
            (List.concatMap convertDictToValidation
                [ customerEvents, customerBillingAddressEvents, customerDeliveryAddressEvents, customerCreditCardEvents ]
            )
    in
        -- in the validation of all the fields overall -> are there any False validations?
        -- if so it is not valid
        validationList |> List.any (\a -> a == False) |> not


showSaveButtonIfValid : Customer -> Html Msg
showSaveButtonIfValid customer =
    if validateCustomer customer then
        div [ onClick (Save customer), class "material-icons" ] [ text "save" ]
    else
        div [] []


editView : Customer -> Html Msg
editView customer =
    li [ class "customer", class ("id-" ++ customer.id) ]
        [ div [ onClick (Show customer), class "material-icons" ] [ text "cancel" ]
        , showSaveButtonIfValid customer
        , div [ class "businessCard" ]
            [ img [ src customer.pictureUrl, class "picture" ] []
            , div [ class "bigLineHeight", class "businessCard__info" ] (editInfo customer)
            ]
        , div [ class "customer__detail" ]
            [ editCustomerAddress "Delivery Address" customer customerDeliveryAddressEvents
            , editCustomerCreditCard customer customerCreditCardEvents
            , editCustomerAddress "Billing Address" customer customerBillingAddressEvents
            ]
        ]


showCustomerCreditCard : Customer -> EventDict -> Html Msg
showCustomerCreditCard customer customerAddressEvents =
    viewCustomerCreditCard (modelShowInputMapper customer customerAddressEvents)


editCustomerCreditCard : Customer -> EventDict -> Html Msg
editCustomerCreditCard customer customerAddressEvents =
    viewCustomerCreditCard (modelEditInputMapper customer customerAddressEvents)


viewCustomerCreditCard : InputMapperFunction -> Html Msg
viewCustomerCreditCard htmlFunc =
    div []
        [ h3 [] [ text "Billing Information" ]
        , div [ class "bigLineHeight" ]
            [ htmlFunc [ class "number" ] "number"
            , htmlFunc [ class "expDate" ] "expDate"
            , htmlFunc [ class "csv" ] "csv"
            ]
        ]


showCustomerAddress : String -> Customer -> EventDict -> Html Msg
showCustomerAddress label customer addressEvents =
    viewCustomerAddress (modelShowInputMapper customer addressEvents) label


editCustomerAddress : String -> Customer -> EventDict -> Html Msg
editCustomerAddress label customer addressEvents =
    viewCustomerAddress (modelEditInputMapper customer addressEvents) label


viewCustomerAddress : InputMapperFunction -> String -> Html Msg
viewCustomerAddress htmlFunc label =
    div []
        [ h3 [] [ text label ]
        , div [ class "bigLineHeight" ]
            [ htmlFunc [ class "businessCard__line", class "street" ] "street"
            , htmlFunc [ class "businessCard__line", class "city" ] "city"
            , htmlFunc [ class "businessCard__line", class "state" ] "state"
            , htmlFunc [ class "businessCard__line", class "postcode" ] "postcode"
            , htmlFunc [ class "businessCard__line", class "country" ] "country"
            ]
        ]
