module Test.Core exposing (main)
import Test exposing (describe, test)
import Test.Runner.Html exposing (run)


import Core
import SignIn
import Msg exposing(Msg(..))
import Expect
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
main =
    run <| all



all: Test.Test
all =
    describe "Core"
        [ describe "update"
         [
          describe "Msg (SelectPage Int)" [
               test "without a signInModel.accountModel the model will not change" <|
                   \_ ->
                        let
                            initialModel = Core.init |> Tuple.first
                            model = Tuple.first <| Core.update (SelectPage 1) initialModel

                        in
                            Expect.equal initialModel model

               , test "with a signInModel.accountModel the model will change selectedPageIndex" <|
                   \_ ->
                        let
                            initialModel = Core.init |> Tuple.first
                            signInModel  = SignIn.initModel
                            signedInSignInModel = { signInModel | accountModel = Just <| SignIn.Account "name"}
                            model = Tuple.first <| Core.update (SelectPage 1) {initialModel| signInModel = signedInSignInModel}

                        in
                            Expect.equal 1 model.selectedPageIndex
              ]
         ]
        ]
