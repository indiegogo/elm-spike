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
import Models.Customer exposing (Customer, CustomerAddress, CustomerCreditCard)


testModel =
    DetailList.Model customerList "" 1 5 300


customerList =
    [ customer1, customer2, customer3, fullCustomer ]


customer1 =
    Customer ""
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
    Customer ""
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
    Customer ""
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


fullCustomer : Customer
fullCustomer =
    { pictureUrl = "http//fake.url/1"
    , birthday = "06/04/2010"
    , company = "Ponyland Inc"
    , fullname = "Rainy Corn"
    , phone = "415-632-6001"
    , email = "rain@friendship.com"
    , title = "Unicorn Pony"
    , id = "ABC123"
    , deliveryAddress = { street = "38th Street", city = "Vacaville", state = "ca", postcode = "99210", country = "USA" }
    , billingAddress = { street = "1st Street", city = "Ponytown", state = "ca", postcode = "98211", country = "PONY" }
    , creditCard = { number = "4242 4242 4242 4242", expDate = "02/20", csv = "093" }
    }


customerDataTests output =
    describe "Basic Customer Data"
        [ test "Mr Dave is on the page" <|
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


customerDetailTests output =
    describe "Customer Details"
        [ test "fullCustomer name appears with name class" <|
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


calcCustomersToShowTests =
    describe "Customers To Show" <|
        [ describe "calcCustomersToShow" <|
            [ test "with size (800 h,640 w)" <|
                \_ ->
                    DetailList.calcCustomersToShow testModel { height = 800, width = 640 }
                        |> Expect.equal 2
            , test "with size (800 h,700 w)" <|
                \_ ->
                    DetailList.calcCustomersToShow testModel { height = 800, width = 700 }
                        |> Expect.equal 2
            , test "with size (800 h,1200 w)" <|
                \_ ->
                    DetailList.calcCustomersToShow testModel { height = 800, width = 1200 }
                        |> Expect.equal 4
            ]
        ]


displayWindowTests =
    describe "Customer display Window customer list" <|
        [ describe "with customersToShow 3" <|
            [ test "with currentCustomer index 0 returns customer from position 1,2,3" <|
                \_ ->
                    DetailList.customerWindow
                        { customers = customerList
                        , customersToShow = 3
                        , currentCustomerIndex = 0
                        }
                        |> Expect.equal (List.take 3 customerList)
            , test "with currentCustomerIndex 3 returns customer from position 4, 1, 2" <|
                \_ ->
                    DetailList.customerWindow
                        { customers = customerList
                        , customersToShow = 3
                        , currentCustomerIndex = 3
                        }
                        |> Expect.equal
                            ((List.take 1 (List.reverse customerList))
                                ++ (List.take 2 customerList)
                            )
                           -- [4,1,2] (indexes used)
            ]
        ]


all : Test.Test
all =
    let
        output =
            DetailList.view testModel |> Query.fromHtml
    in
        describe "DetailList"
            [ displayWindowTests
            , calcCustomersToShowTests
            , customerDataTests output
            , customerDetailTests output
            ]
