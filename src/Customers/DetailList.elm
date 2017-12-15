module Customers.DetailList exposing (..)

import Array exposing (Array)
import Html exposing (Html, div, text, li)
import Html.Attributes exposing (class)
import Http
import Models.FirebaseCustomer exposing (FirebaseCustomer, encodeFirebaseCustomerList)
import Utils.RandomUser exposing (RandomUserMe, importFromRandomUserMe, randomUserMeToCustomers)


type alias Model =
    { customers : Array FirebaseCustomer
    , errorMsg : String
    }


type Actions
    = ImportCustomers (Result Http.Error RandomUserMe)


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
    (Model (Array.fromList []) "")


init : ( Model, Cmd Actions )
init =
    ( initModel, importFromRandomUserMe ImportCustomers "10" )


view : Model -> Html msg
view model =
    div [] [
         text "hi i'm details list"
    , div [] (customerList model)
        ]

customerToHtml: FirebaseCustomer -> Html msg
customerToHtml customer =
    li []
        [ div [ class "name" ] [ text customer.fullname ]
        , div [ class "company" ] [ text customer.company ]
        , div [ class "birthday" ] [ text customer.birthday ]
        ]

customerList : Model -> List (Html msg)
customerList model =
    Array.map customerToHtml
        model.customers
        |> Array.toList


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


update : Actions -> Model -> ( Model, Cmd Actions )
update msg model =
    case msg of
        ImportCustomers result ->
            let
                firebaseCustomerList randomUserMe =
                    encodeFirebaseCustomerList <| randomUserMeToCustomers randomUserMe
            in
                case result of
                    Ok randomUserMe ->
                        --{model |customers = (firebaseCustomerList randomUserMe)}
                        ( model, Cmd.none )

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
