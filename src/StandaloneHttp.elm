
module StandaloneHttp exposing(main)
-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Response)
import Json.Decode as Decode



main =
  Html.program
    { init = init "cats"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { topic : String
  , gifUrl : String
  , message : String
  }


init : String -> (Model, Cmd Msg)
init topic =
  ( Model topic "waiting.gif" "DefaultMessage"
  , getRandomGif topic
  )



-- UPDATE


type Msg
  = MorePlease
  | NewGif (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, getRandomGif model.topic)

    NewGif (Ok newUrl) ->
      (Model model.topic newUrl "Ok Url", Cmd.none)

    NewGif (Err err) ->
       case err of 
         Http.BadUrl str ->
         (Model model.topic "https://cdn.dribbble.com/users/644529/screenshots/2662296/404.gif" "BadUrl", Cmd.none)
         Http.Timeout -> 
         (Model model.topic "https://cdn.dribbble.com/users/644529/screenshots/2662296/404.gif" "Timeout", Cmd.none)
         Http.NetworkError -> 
         (Model model.topic "https://cdn.dribbble.com/users/644529/screenshots/2662296/404.gif" "NetworkError", Cmd.none)
         Http.BadStatus _ ->
         (Model model.topic "https://cdn.dribbble.com/users/644529/screenshots/2662296/404.gif" "BadStatus", Cmd.none)
         Http.BadPayload _ _ ->
         (Model model.topic "https://cdn.dribbble.com/users/644529/screenshots/2662296/404.gif" "BadPayload" , Cmd.none)
       


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text model.topic]
    , button [ onClick MorePlease ] [ text "More Please!" ]
    , br [] []
    , img [src model.gifUrl] []
    , br [] []
    , h3 [] [ text model.message]
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Http.send NewGif (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
  Decode.at ["data", "image_url"] Decode.string
