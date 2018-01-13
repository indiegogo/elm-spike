module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type alias CustomerId = String

type Route =
     CustomersRoute
   | CustomerDetailRoute CustomerId
   | DBTestRoute
   | InventoryRoute
   | OrdersRoute
   | SignInRoute
   | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map SignInRoute (s "")
        , map CustomerDetailRoute (s "customerDetail" </> string)
        , map CustomersRoute (s "customers")
        , map OrdersRoute (s "orders")
        , map InventoryRoute (s "inventory")
        , map DBTestRoute (s "dbtest")
        ]

urlFor route =
    case route of
      SignInRoute ->
          ""
      CustomersRoute ->
          "customers"
      CustomerDetailRoute id ->
          "customerDetail/" ++ id
      DBTestRoute ->
          "dbtest"
      InventoryRoute ->
          "inventory"
      OrdersRoute ->
          "orders"
      _ ->
          "404"



parseLocation : Location -> Route
parseLocation location =
    let
         p = Debug.log "parseLocation:location" location
    in
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
