module Models.FirebaseCustomer exposing(FirebaseCustomer, CustomerAddress, CustomerCreditCard,initModel, encodeFirebaseCustomerList, decodeFirebaseCustomerList)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline as DecodePipeline


initModel: FirebaseCustomer 
initModel =
    FirebaseCustomer "" "" "" "" "" "" "" ""
        (CustomerAddress "" "" "" "" "")
        (CustomerAddress "" "" "" "" "")
        (CustomerCreditCard "" "" "")



type alias FirebaseCustomer =
    { pictureUrl : String
    , birthday : String
    , company : String
    , fullname : String
    , phone : String
    , email : String
    , title : String
    , id : String
    , deliveryAddress : CustomerAddress
    , billingAddress : CustomerAddress
    , creditCard : CustomerCreditCard
    }


type alias CustomerCreditCard =
    { number : String
    , expDate : String
    , csv : String
    }

type alias CustomerAddress =
    { street : String
    , city : String
    , state : String
    , postcode : String
    , country : String
    }


decodeFirebaseCustomerList : Decode.Decoder (List FirebaseCustomer)
decodeFirebaseCustomerList =
    Decode.list decodeFirebaseCustomer



--
-- BUG WARNING
-- Note: The order of the decoder fields
--       must correspond to the order for fields of the type alias
--


decodeFirebaseCustomer : Decode.Decoder FirebaseCustomer
decodeFirebaseCustomer =
    DecodePipeline.decode FirebaseCustomer
        |> DecodePipeline.required "pictureUrl" Decode.string
        |> DecodePipeline.required "birthday" Decode.string
        |> DecodePipeline.required "company" Decode.string
        |> DecodePipeline.required "fullname" Decode.string
        |> DecodePipeline.required "phone" Decode.string
        |> DecodePipeline.required "email" Decode.string
        |> DecodePipeline.required "title" Decode.string
        |> DecodePipeline.required "id" Decode.string
        |> DecodePipeline.required "deliveryAddress" decodeCustomerAddress
        |> DecodePipeline.required "billingAddress" decodeCustomerAddress
        |> DecodePipeline.required "creditCard" decodeCustomerCreditCard


decodeCustomerCreditCard : Decode.Decoder CustomerCreditCard
decodeCustomerCreditCard =
    DecodePipeline.decode CustomerCreditCard
        |> DecodePipeline.required "number" Decode.string
        |> DecodePipeline.required "expDate" Decode.string
        |> DecodePipeline.required "csv" Decode.string


decodeCustomerAddress : Decode.Decoder CustomerAddress
decodeCustomerAddress =
    DecodePipeline.decode CustomerAddress
        |> DecodePipeline.required "street" Decode.string
        |> DecodePipeline.required "city" Decode.string
        |> DecodePipeline.required "state" Decode.string
        |> DecodePipeline.required "postcode" Decode.string
        |> DecodePipeline.required "country" Decode.string


encodeCustomerCreditCard : CustomerCreditCard -> Encode.Value
encodeCustomerCreditCard record =
    Encode.object
        [ ( "number", Encode.string <| record.number )
        , ( "expDate", Encode.string <| record.expDate )
        , ( "csv", Encode.string <| record.csv )
        ]


encodeCustomerAddress : CustomerAddress -> Encode.Value
encodeCustomerAddress record =
    Encode.object
        [ ( "street", Encode.string <| record.street )
        , ( "city", Encode.string <| record.city )
        , ( "state", Encode.string <| record.state )
        , ( "postcode", Encode.string <| record.postcode )
        , ( "country", Encode.string <| record.country )
        ]


encodeFirebaseCustomer : FirebaseCustomer -> Encode.Value
encodeFirebaseCustomer record =
    Encode.object
        [ ( "pictureUrl", Encode.string <| record.pictureUrl )
        , ( "birthday", Encode.string <| record.birthday )
        , ( "company", Encode.string <| record.company )
        , ( "fullname", Encode.string <| record.fullname )
        , ( "phone", Encode.string <| record.phone )
        , ( "email", Encode.string <| record.email )
        , ( "title", Encode.string <| record.title )
        , ( "id", Encode.string <| record.id )
        , ( "creditCard", encodeCustomerCreditCard <| record.creditCard )
        , ( "deliveryAddress", encodeCustomerAddress <| record.deliveryAddress )
        , ( "billingAddress", encodeCustomerAddress <| record.billingAddress )
        ]


encodeFirebaseCustomerList : List FirebaseCustomer -> Encode.Value
encodeFirebaseCustomerList customers =
    Encode.list <| List.map encodeFirebaseCustomer <| customers
