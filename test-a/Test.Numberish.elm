module Test.Numberish exposing(..)
import Test exposing (..)
import Test.Runner.Html exposing(..)
import Expect

main: TestProgram
main = run all



type Numberish =
    SNum String | INum Int | FNum Float

eq: Numberish -> Numberish -> Bool
eq a b =
    case a of
        SNum stra ->
          case b of
              SNum strb ->
                  ((stra == strb))
              INum intb ->
                  ((toString intb == stra))
              FNum floatb ->
                  ((toString floatb == stra))
        INum inta ->
          case b of
              SNum strb ->
                  ((toString inta == strb))
              INum intb ->
                  ((intb == inta))
              FNum floatb ->
                  ((floatb == toFloat inta))
        FNum floata ->
          case b of
              SNum strb ->
                  ((strb == toString floata))
              INum intb ->
                  ((toFloat intb == floata))
              FNum floatb ->
                  ((floatb == floata))

all : Test
all = describe "Numberish" [
       test "(ne (INum 1) (FNum 1.0))" <|
           \_ -> Expect.true "1 == 1.0" (eq  (INum 1) (FNum 1.0))
    ,   test "(ne  (INum 1) (SNum \"1\"))" <|
           \_ -> Expect.true "1 == \"1\"" (eq  (INum 1) (SNum "1"))
    ,   test "(ne  (FNum 1.000019) (SNum \"1.000019\"))" <|
           \_ -> Expect.true "1.000019 == \"1.000019\"" (eq  (FNum 1.000019) (SNum "1.000019"))
      ]

