module Contact.Json exposing (Contact)

import Json.Encode
import Json.Decode
import Json.Decode.Pipeline


type alias Contact =
    { name : String
    , email : String
    , adddress1 : String
    , addresss2 : String
    , city : String
    }

type alias ContactsResponse =
    { contacts : List Contact
    }

decodeContactsResponse : Json.Decode.Decoder ContactsResponse
decodeContactsResponse =
    Json.Decode.Pipeline.decode ContactsResponse
        |> Json.Decode.Pipeline.required "contacts" (Json.Decode.list decodeContact)

encodeContactsResponse : ContactsResponse -> Json.Encode.Value
encodeContactsResponse record =
    Json.Encode.object
        [ ("contacts",  Json.Encode.list <| List.map encodeContact <| record.contacts)
        ]

decodeContact : Json.Decode.Decoder Contact
decodeContact =
    Json.Decode.Pipeline.decode Contact
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "email" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "adddress1" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "addresss2" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "city" (Json.Decode.string)

encodeContact : Contact -> Json.Encode.Value
encodeContact record =
    Json.Encode.object
        [ ("name",  Json.Encode.string <| record.name)
        , ("email",  Json.Encode.string <| record.email)
        , ("adddress1",  Json.Encode.string <| record.adddress1)
        , ("addresss2",  Json.Encode.string <| record.addresss2)
        , ("city",  Json.Encode.string <| record.city)
        ]
