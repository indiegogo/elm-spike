import Html exposing (Html, div, text)
import Contact.Json exposing (Contact)

type alias Model =
    {
        contacts: List Contact
    }



init: (Model, Cmd msg)
init =
    ({ contacts = [] }, Cmd.none)
main: Program Never Model msg
main =
  Html.program
      {
        init = init
      , view = view
      , update = update
      , subscriptions = subscriptions
      }

update: msg -> Model -> (Model, Cmd msg)
update msg model =
 ( model, Cmd.none)

view: Model -> Html msg
view model =
  div [] [ text (toString model) ]

subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none
