module Customers.DetailList exposing (..)

import Html exposing (Html, div, text, li, ol, button, img, h3)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, style, src)
import Http
import Models.Customer as Customer exposing (Customer, CustomerAddress, CustomerCreditCard, encodeCustomerList)
import Window
import Task
import Debug as D
import Array
import Views.Customer as CView
import Json.Decode as Decode
import Dict

type alias Model =
    {
     errorMsg : String
    , currentCustomerIndex : Int
    , customersToShow : Int
    , cardWidth : Int
    , editableCustomer : Maybe Customer
    , customersById : Customer.CustomersById
    }


type Actions
    = Resize Window.Size
    | Next
    | Previous
    | CustomerMsg CView.Msg
    | Validation (Result Http.Error String)
    --| ImportCustomers (Result Http.Error RandomUserMe)


initModel : Model
initModel =
    (Model "" 0 3 400 Nothing Customer.emptyCustomersById)


initCmd : Cmd Actions
initCmd =
    Cmd.batch
        [
         --  importFromRandomUserMeWithSeed ImportCustomers "10" "abc123-seed"
         Task.perform Resize Window.size
        ]


view : Model -> Html Actions
view model =
    div [ class "customer-list" ]
        [ button [ onClick Previous ] [ text "Previous" ]
        , ol [] (customerList model)
        , button [ onClick Next ] [ text "Next" ]
        ]


customerList : Model -> List (Html Actions)
customerList { customersToShow, currentCustomerIndex, editableCustomer, customersById } =
    List.map (Html.map CustomerMsg)
        (List.map (customerToHtmlFunction editableCustomer) <|
            customerWindow
                { customers = Dict.values customersById
                , customersToShow = customersToShow
                , currentCustomerIndex = currentCustomerIndex
                }
        )



-- generate a function that takes the possibly editable customer and
--

customerToHtmlFunction: Maybe Customer -> (Customer -> Html CView.Msg)
customerToHtmlFunction editableCustomer =
    case editableCustomer of
        Nothing ->
            (\customer ->
                CView.showView customer
            )

        Just editCustomer ->
            (\customer ->
                if editCustomer.id == customer.id then
                    CView.editView editCustomer
                else
                    CView.showView customer
            )


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
        array =
            Array.fromList customers

        len =
            List.length customers

        start =
            currentCustomerIndex

        end =
            currentCustomerIndex + customersToShow

        indexes =
            case len of
                0 ->
                    List.range start end

                _ ->
                    List.range start end |> List.map (\idx -> idx % len)

        lookup_customer_index indexPosition =
            Array.get indexPosition (Array.fromList indexes) |> Maybe.withDefault 0

        lookup_customer customerPosition =
            Maybe.withDefault Customer.emptyCustomer
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
    width // model.cardWidth

lengthOfCustomers: Dict.Dict String Customer -> Int
lengthOfCustomers customersById =
    List.length <| Dict.values customersById

-- % is not safe from divzero runtime (0.18 elm)
nextCustomerIndex : Model -> Int
nextCustomerIndex { currentCustomerIndex, customersById } =
    (currentCustomerIndex + 1) % (lengthOfCustomers customersById)



-- % is not safe from divzero runtime (0.18 elm)
prevCustomerIndex : Model -> Int
prevCustomerIndex { currentCustomerIndex, customersById } =
    (currentCustomerIndex - 1) % (lengthOfCustomers customersById)


decodeServerValidate =
    Decode.at ["ok"] Decode.string

postWithCred url body =
    Http.request
    { method = "POST"
    , headers = []
    , url = url
    , body = body
    , expect = Http.expectJson decodeServerValidate
    , timeout = Nothing
    , withCredentials = True -- send cookies
    }

customerToBody customer =
    Http.emptyBody

-- todo server side validations
checkServerSideValidation: Maybe Customer ->  Cmd Actions
checkServerSideValidation maybeCustomer =
    case maybeCustomer of
        Nothing ->
            Cmd.none
        Just customer ->
            Http.send Validation ( postWithCred "http://localhost:4000/api/validate/customer" (customerToBody customer))


update : Actions -> Model -> ( Model, Cmd Actions )
update msg model =
    case msg of
        Validation result ->
            case result of
                Ok str ->
                    let
                        a = Debug.log "str"
                    in
                        (model, Cmd.none)

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

        CustomerMsg cmsg ->
            case cmsg of
                CView.Show customer ->
                    ( { model | editableCustomer = Nothing }, Cmd.none )

                -- TODO delegate to Edit Customer Sub Program
                CView.Edit customer ->
                    ( { model | editableCustomer = Just customer }, Cmd.none )

                -- TODO delegate to Edit Customer Sub Program
                CView.Save customer ->
                    let
                        customersById = model.customersById


                        replaceCustomer maybeCustomer =
                            case maybeCustomer of
                                Nothing ->
                                    Nothing
                                Just customer ->
                                    model.editableCustomer

                        -- Performance Issue (Dict is better than a full list scan!)
                        --

                        updatedCustomers = Dict.update customer.id replaceCustomer customersById
                    in
                        ( { model | editableCustomer = Nothing
                          , customersById = updatedCustomers 
                          }
                          , (checkServerSideValidation model.editableCustomer)
                        )
                -- TODO delegate to Edit Customer Sub Program
                CView.Update event ->
                    ( { model | editableCustomer = CView.update event model.editableCustomer }
                    , Cmd.none
                    )

        Next ->
            ( { model | currentCustomerIndex = nextCustomerIndex model }, Cmd.none )

        Previous ->
            ( { model | currentCustomerIndex = prevCustomerIndex model }, Cmd.none )

        Resize windowSize ->
            ( { model | customersToShow = calcCustomersToShow model windowSize }, Cmd.none )
{-

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
-}
