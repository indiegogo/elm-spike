module Test.Firebase.DB exposing (..)

import Expect
import Firebase.DB
import Test exposing (..)


-- import Test.Runner.Html exposing (run)
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
-- main =
--     run <| all


all : Test.Test
all =
    describe "Firebase Id Sanitize"
        [ test "sanitizeId" <|
            \_ ->
                Expect.equal (Firebase.DB.sanitizeId ".0-10.10") "-0-10-10"
        ]
