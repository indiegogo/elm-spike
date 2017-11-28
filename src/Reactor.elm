module Reactor exposing (update, view, init, subscriptions, location2messages, delta2url)

import Debug as D exposing (log)
import RouteUrl as Routing
import Navigation
import Dict
import Msg exposing (Msg(..))

import Layout
import SignIn


type alias CustomerModel =
    { list : List String
    }


type alias EmptyModel =
    {}


type alias Account =
    { username : String
    }


type alias Model =
    { customersModel : CustomerModel
    , ordersModel : EmptyModel
    , inventoryModel : EmptyModel
    , selectedPageIndex : Int
    , signInModel : SignIn.Model
    , accountModel : Maybe Account
    }


model =
    { customersModel = CustomerModel [ "joe", "sue", "betty", "wilma", "frank" ]
    , ordersModel = EmptyModel
    , inventoryModel = EmptyModel
    , selectedPageIndex = 0
    , signInModel = SignIn.initModel
    , accountModel = Nothing
    }



--
-- Init establishes the basic data structure.
--


init =
    let
        c =
            D.log "function" "init"
    in
        ( model
        , Cmd.none
        )



-- Update is a triggered by a Msg which represents
-- a particular side-effect generated by an actor
--


update msg model =
    let
        a =
            D.log "model" model

        b =
            D.log "msg" msg

        c =
            D.log "update"
    in
        case msg of
            SelectPage idx ->
                case model.accountModel of
                    Just a ->
                        ( {model| selectedPageIndex = idx}, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

            SignInPage msg ->
                let
                    next =
                        (SignIn.update msg model.signInModel)

                    signInModel =
                        (Tuple.first next)

                    cmd =
                        Tuple.second next
                in
                    case signInModel.state of
                        SignIn.Valid ->
                         ( {model| accountModel = (Just (Account signInModel.username))
                                   ,selectedPageIndex = 1 
                           }, cmd )
                        _ ->
                        ( { model | signInModel = signInModel }, cmd )

            CustomersPage msg ->
                ( model, Cmd.none )

            EmptyPage msg ->
                ( model, Cmd.none )

            SignOut ->
                ( { model
                    | accountModel = Nothing
                    , selectedPageIndex = 0
                  }
                , Cmd.none
                )


view model =
    Layout.view model


subscriptions model =
    Sub.none


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedPageIndex /= model2.selectedPageIndex then
        { entry = Routing.NewEntry
        , url = Layout.urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    let
        a =
            D.log "location2messages -> location" location
    in
        [ case String.dropLeft 1 location.hash of
            "" ->
                SelectPage 0

            x ->
                Dict.get x Layout.urlTabs
                    |> Maybe.withDefault -1
                    |> SelectPage
        ]
