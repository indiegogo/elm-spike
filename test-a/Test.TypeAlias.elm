module Test.TypeAlias exposing(..)
import Test exposing (..)
import Test.Runner.Html exposing(..)
import Expect

main: TestProgram
main = run all

{-
   Customer name =
        {name: name}
-}



 {-
    a different Customer Definition
    that has fields that User does not
 -}

type alias Customer = {
        name : { first: String, last:String }
    , address : String
    }

{-

Customer name address =
        {name: name, address: address}
-}
type alias User =
    { name : { first: String, last:String }}

{- type Account =
    AccountUser User
-}
{-
type alias Customer = {
        name : { first: String, last:String }
    }
-}


myConcreteRecord: { name : { first: String, last:String }}
myConcreteRecord =
  {
     name = { first= "Snowanna", last="Rainbeau"}
  }

customerName: Customer -> String
customerName {name} =
         name.first ++ " " ++ name.last



-- "parametric polymorphism"
fullname: { a | name : {b | first : String, last: String} } -> String
fullname {name} =
         name.first ++ " " ++ name.last



all : Test
all = describe "TypeAlias" [
       test "Swizzle Malarky" <|
           \_ -> Expect.equal
                 (fullname <| Customer {first="Swizzle", last="Malarky"} "Address")
                 -- (fullname <| Customer {first="Swizzle", last="Malarky"})
                 "Swizzle Malarky"
       , test "Snowanna Rainbeau" <|
           \_ -> Expect.equal
                 (fullname <| myConcreteRecord)
                 (customerName <| User myConcreteRecord.name)

       , test "Snowanna Rainbeau" <|
           \_ -> Expect.equal
                 (fullname <| myConcreteRecord)
                 (customerName <| Customer myConcreteRecord.name)
--                 (customerName <| AccountUser myConcreteType)
       , test "Minty Zaki" <|
           \_ -> Expect.equal
                 (fullname <| User {first="Minty", last="Zaki"})
                 "Minty Zaki"
      ]

