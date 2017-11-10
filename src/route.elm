module Route exposing (Route(..), fromLocation)
import Navigation exposing (Location)

type Route
    = Home
    | Blank

fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        case location.hash of
            "#blank" ->
                Just Blank
            "#home"  ->
                Just Home
            _  -> Nothing




