module Route exposing (Route(..), fromLocation)
import Navigation exposing (Location)

type Route
    = HomeRoute
    | BlankRoute

fromLocation location =
    if String.isEmpty location.hash then
        Just HomeRoute
    else
        case location.hash of
            "#blank" ->
                Just BlankRoute
            "#home"  ->
                Just HomeRoute
            _  ->
                Nothing




