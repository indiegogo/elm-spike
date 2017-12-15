module Utils.RandomUser exposing(..)

import Json.Encode
import Json.Decode
-- elm-package install -- yes noredink/elm-decode-pipeline
import Json.Decode.Pipeline
import Models.Customer exposing(Customer)
import Http


importFromRandomUserMe: ( (Result Http.Error RandomUserMe) -> msg) -> String -> Cmd msg
importFromRandomUserMe msg importAmount =
    Http.send msg (Http.get ("https://randomuser.me/api/?results=" ++ importAmount) decodeRandomUserMe)

randomUserMeToCustomers : RandomUserMe -> List Customer
randomUserMeToCustomers list =
    List.map
        (\randomUser -> mapRandomUserToCustomer randomUser)
        list.results

-- id for firebase must not contain
-- ".", "#", "$", "/", "[", or "]"


sanitizeList : List String
sanitizeList =
    [ ".", "#", "$", "/", "[", "]" ]


sanitizeId : String -> String
sanitizeId idForFirebase =
    String.map
        (\char ->
            case List.member (String.fromChar char) sanitizeList of
                True ->
                    '-'

                _ ->
                    char
        )
        idForFirebase
-- https://github.com/rainteller/elm-capitalize/blob/master/Capitalize.elm


toCapital : String -> String
toCapital str =
    String.toUpper (String.left 1 str) ++ String.dropLeft 1 str


mapRandomUserToCustomer : RandomUser -> Customer
mapRandomUserToCustomer r =
    let
        a =
            Debug.log "randomUser" r
    in
        { email = r.email
        , fullname = List.foldr (++) "" <| List.map (\s -> toCapital s) [ r.name.title, " ", r.name.first, " ", r.name.last ]
        , phone = r.phone
        , birthday = r.dob
        , company = "Random User"
        , id = sanitizeId <| r.id.name ++ (Maybe.withDefault "" <| r.id.value)
        , pictureUrl = r.picture.large
        , title = ""
        , deliveryAddress =
            { street = r.location.street
            , city = r.location.city
            , state = r.location.state
            , postcode = toString r.location.postcode
            , country = ""
            }
        , billingAddress =
            { street = r.location.street
            , city = r.location.city
            , state = r.location.state
            , postcode = toString r.location.postcode
            , country = ""
            }
        , creditCard =
            { number = ""
            , expDate = ""
            , csv = ""
            }
        }


type alias RandomUserMe =
    { results : List RandomUser
    , info : RandomUserMeInfo
    }

type alias RandomUserMeInfo =
    { seed : String
    , results : Int
    , page : Int
    , version : String
    }

type alias RandomUser =
    { gender : String
    , name : RandomUserName
    , location : RandomUserLocation
    , email : String
    , login : RandomUserLogin
    , dob : String
    , registered : String
    , phone : String
    , cell : String
    , id : RandomUserId
    , picture : RandomUserPicture
    , nat : String
    }

type alias RandomUserName =
    { title : String
    , first : String
    , last : String
    }

type PostCode =
     StringPostCode String | IntPostCode Int

type alias RandomUserLocation =
    { street : String
    , city : String
    , state : String
    , postcode : PostCode 
    }

type alias RandomUserLogin =
    { username : String
    , password : String
    , salt : String
    , md5 : String
    , sha1 : String
    , sha256 : String
    }

type alias RandomUserId =
    { name : String
    , value : Maybe String
    }

type alias RandomUserPicture =
    { large : String
    , medium : String
    , thumbnail : String
    }

decodeRandomUserMe : Json.Decode.Decoder RandomUserMe
decodeRandomUserMe =
    Json.Decode.Pipeline.decode RandomUserMe
        |> Json.Decode.Pipeline.required "results" (Json.Decode.list decodeRandomUser)
        |> Json.Decode.Pipeline.required "info" (decodeRandomUserMeInfo)

decodeRandomUserMeInfo : Json.Decode.Decoder RandomUserMeInfo
decodeRandomUserMeInfo =
    Json.Decode.Pipeline.decode RandomUserMeInfo
        |> Json.Decode.Pipeline.required "seed" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "results" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "page" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "version" (Json.Decode.string)

encodeRandomUserMe : RandomUserMe -> Json.Encode.Value
encodeRandomUserMe record =
    Json.Encode.object
        [ ("results",  Json.Encode.list <| List.map encodeRandomUser <| record.results)
        , ("info",  encodeRandomUserMeInfo <| record.info)
        ]

encodeRandomUserMeInfo : RandomUserMeInfo -> Json.Encode.Value
encodeRandomUserMeInfo record =
    Json.Encode.object
        [ ("seed",  Json.Encode.string <| record.seed)
        , ("results",  Json.Encode.int <| record.results)
        , ("page",  Json.Encode.int <| record.page)
        , ("version",  Json.Encode.string <| record.version)
        ]

decodeRandomUser : Json.Decode.Decoder RandomUser
decodeRandomUser =
    Json.Decode.Pipeline.decode RandomUser
        |> Json.Decode.Pipeline.required "gender" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "name" (decodeRandomUserName)
        |> Json.Decode.Pipeline.required "location" (decodeRandomUserLocation)
        |> Json.Decode.Pipeline.required "email" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "login" (decodeRandomUserLogin)
        |> Json.Decode.Pipeline.required "dob" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "registered" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "phone" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "cell" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "id" (decodeRandomUserId)
        |> Json.Decode.Pipeline.required "picture" (decodeRandomUserPicture)
        |> Json.Decode.Pipeline.required "nat" (Json.Decode.string)

decodeRandomUserName : Json.Decode.Decoder RandomUserName
decodeRandomUserName =
    Json.Decode.Pipeline.decode RandomUserName
        |> Json.Decode.Pipeline.required "title" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "first" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "last" (Json.Decode.string)

decodeRandomUserLocation : Json.Decode.Decoder RandomUserLocation
decodeRandomUserLocation =
    Json.Decode.Pipeline.decode RandomUserLocation
        |> Json.Decode.Pipeline.required "street" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "city" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "state" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "postcode" (Json.Decode.oneOf [decodeLocationPostCodeInt, decodeLocationPostCodeString])

decodeLocationPostCodeInt: Json.Decode.Decoder PostCode
decodeLocationPostCodeInt =
    Json.Decode.map IntPostCode Json.Decode.int
    -- This map is to box up our PostCode Union type into a Decoder type
    -- example : Json.Decode.Decoder IntPostCode 1

decodeLocationPostCodeString: Json.Decode.Decoder PostCode
decodeLocationPostCodeString =
    Json.Decode.map StringPostCode Json.Decode.string

decodeRandomUserLogin : Json.Decode.Decoder RandomUserLogin
decodeRandomUserLogin =
    Json.Decode.Pipeline.decode RandomUserLogin
        |> Json.Decode.Pipeline.required "username" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "password" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "salt" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "md5" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "sha1" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "sha256" (Json.Decode.string)

decodeRandomUserId : Json.Decode.Decoder RandomUserId
decodeRandomUserId =
    Json.Decode.Pipeline.decode RandomUserId
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "value" (Json.Decode.maybe Json.Decode.string )

decodeRandomUserPicture : Json.Decode.Decoder RandomUserPicture
decodeRandomUserPicture =
    Json.Decode.Pipeline.decode RandomUserPicture
        |> Json.Decode.Pipeline.required "large" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "medium" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "thumbnail" (Json.Decode.string)

encodeRandomUser : RandomUser -> Json.Encode.Value
encodeRandomUser record =
    Json.Encode.object
        [ ("gender",  Json.Encode.string <| record.gender)
        , ("name",  encodeRandomUserName <| record.name)
        , ("location",  encodeRandomUserLocation <| record.location)
        , ("email",  Json.Encode.string <| record.email)
        , ("login",  encodeRandomUserLogin <| record.login)
        , ("dob",  Json.Encode.string <| record.dob)
        , ("registered",  Json.Encode.string <| record.registered)
        , ("phone",  Json.Encode.string <| record.phone)
        , ("cell",  Json.Encode.string <| record.cell)
        , ("id",  encodeRandomUserId <| record.id)
        , ("picture",  encodeRandomUserPicture <| record.picture)
        , ("nat",  Json.Encode.string <| record.nat)
        ]

encodeRandomUserName : RandomUserName -> Json.Encode.Value
encodeRandomUserName record =
    Json.Encode.object
        [ ("title",  Json.Encode.string <| record.title)
        , ("first",  Json.Encode.string <| record.first)
        , ("last",  Json.Encode.string <| record.last)
        ]

encodeRandomUserLocation : RandomUserLocation -> Json.Encode.Value
encodeRandomUserLocation record =
    Json.Encode.object
        [ ("street",  Json.Encode.string <| record.street)
        , ("city",  Json.Encode.string <| record.city)
        , ("state",  Json.Encode.string <| record.state)
        , ("postcode",  encodeLocationPostCode <| record.postcode)
        ]
encodeLocationPostCode: PostCode -> Json.Encode.Value
encodeLocationPostCode postcode =
    case postcode of
        IntPostCode a->
            Json.Encode.int a
        StringPostCode a->
            Json.Encode.string a

encodeRandomUserLogin : RandomUserLogin -> Json.Encode.Value
encodeRandomUserLogin record =
    Json.Encode.object
        [ ("username",  Json.Encode.string <| record.username)
        , ("password",  Json.Encode.string <| record.password)
        , ("salt",  Json.Encode.string <| record.salt)
        , ("md5",  Json.Encode.string <| record.md5)
        , ("sha1",  Json.Encode.string <| record.sha1)
        , ("sha256",  Json.Encode.string <| record.sha256)
        ]

encodeRandomUserId : RandomUserId -> Json.Encode.Value
encodeRandomUserId record =
    Json.Encode.object
        [ ("name",  Json.Encode.string <| record.name)
        , ("value",  Json.Encode.string <| Maybe.withDefault "" <| record.value )
        ]

encodeRandomUserPicture : RandomUserPicture -> Json.Encode.Value
encodeRandomUserPicture record =
    Json.Encode.object
        [ ("large",  Json.Encode.string <| record.large)
        , ("medium",  Json.Encode.string <| record.medium)
        , ("thumbnail",  Json.Encode.string <| record.thumbnail)
        ]

