module Route exposing (Route(..), fromLocation)
import Navigation exposing (Location)

type Route
    = Home
    | Login
    | Logout




fromLocation location =
--    if String.isEmpty location.hash then
        Just Home
