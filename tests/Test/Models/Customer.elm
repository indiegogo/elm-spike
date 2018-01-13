module Test.Models.Customer exposing (..)

import Expect
import Models.Customer as Customer
import Test exposing (..)


-- import Test.Runner.Html exposing (run)
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
-- main =
--     run <| all


all : Test.Test
all =
    let
        dict = Customer.emptyCustomersById
    in
    describe "Customer index from id"
        [ test "sanitizeId" <|
            \_ ->
              let
                  id = "missing"
              in
                Expect.equal (Customer.customerIndexFromId id dict ) Nothing
        ]
