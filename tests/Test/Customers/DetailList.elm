module Test.Customers.DetailList exposing (..)

import Expect
import Customers.DetailList as DetailList
import Test exposing (..)


-- import Test.Runner.Html exposing (run)
-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!
-- main =
--     run <| all

import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, class)
import Array
import Models.FirebaseCustomer exposing (FirebaseCustomer, CustomerAddress, CustomerCreditCard)


testModel =
    DetailList.Model (Array.fromList [ customer1, customer2, customer3 , fullCustomer]) ""


customer1 =
    FirebaseCustomer ""
        ""
        "IGG"
        "Mr Dave"
        ""
        ""
        "CEO"
        "id"
        (CustomerAddress "" "" "" "" "")
        (CustomerAddress "" "" "" "" "")
        (CustomerCreditCard "" "" "")


customer2 =
    FirebaseCustomer ""
        ""
        "IGG"
        "Mr Slava"
        ""
        ""
        "New Business"
        "id"
        (CustomerAddress "" "" "" "" "")
        (CustomerAddress "" "" "" "" "")
        (CustomerCreditCard "" "" "")


customer3 =
    FirebaseCustomer ""
        ""
        "IGG"
        "Mrs Danae"
        ""
        ""
        "Founder"
        "id"
        (CustomerAddress "" "" "" "" "")
        (CustomerAddress "" "" "" "" "")
        (CustomerCreditCard "" "" "")

fullCustomer: FirebaseCustomer
fullCustomer =
    {
        pictureUrl = "http//fake.url/1"
       ,birthday = "06/04/2010"
       ,company  = "Ponyland Inc"
       ,fullname = "Rainy Corn"
       ,phone    = ""
       ,email    = ""
       ,title    = ""
       ,id       = ""
       ,deliveryAddress = { street = "", city = "", state = "", postcode = "", country = ""}
       ,billingAddress = { street = "", city = "", state = "", postcode = "", country = ""}
       ,creditCard     = { number= "4242 4242 4242 4242", expDate = "02/20", csv = "093"}
    }

all : Test.Test
all =
    let
        output =
            DetailList.view testModel |> Query.fromHtml
    in
        describe "DetailList"
            [ describe "Basic Customer Data"
                [test "Mr Dave is on the page" <|
                    \_ ->
                        output
                            |> Query.findAll [ text "Mr Dave" ]
                            |> Query.count (Expect.equal 1)
                , test "Mr Slava is on the page" <|
                    \_ ->
                        output
                            |> Query.findAll [ text "Mr Slava" ]
                            |> Query.count (Expect.equal 1)
                , test "Mrs Danae is on the page" <|
                    \_ ->
                        output
                            |> Query.findAll [ text "Mrs Danae" ]
                            |> Query.count (Expect.equal 1)
                ]
            , describe "Customer Details"
                [
                 test "fullCustomer name appears with name class" <|
                     \_ ->
                        output
                         |> Query.findAll [ tag "div", class "name", text (fullCustomer.fullname) ]
                         |> Query.count (Expect.equal 1)
                 , test "fullCustomer company appears with company class" <|
                     \_ ->
                        output
                         |> Query.findAll [ tag "div", class "company", text (fullCustomer.company) ]
                         |> Query.count (Expect.equal 1)
                 , test "fullCustomer birthday appears with birthday class" <|
                     \_ ->
                        output
                         |> Query.findAll [ tag "div", class "birthday", text (fullCustomer.birthday) ]
                         |> Query.count (Expect.equal 1)
                 
                ]
            ]
