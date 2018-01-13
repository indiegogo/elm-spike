module Session
    exposing
        ( SessionStatus(..)
        , Account
        , Session
        , init
        , setRoute
        , fromFirebaseAuth
        )

import Firebase.Auth exposing (AuthStatus)
import Routing exposing(Route, Route(..))

type SessionStatus
    = InValid
    | Verifying
    | Valid


type alias Account =
    { username : String
    }


type alias Session =
    { pageIndex : Int
    , route   : Route
    , account : Maybe Account
    , status : SessionStatus
    }


init : Session
init =
    Session 0 SignInRoute Nothing InValid


setRoute session route =
    case session.status of
        Valid ->
            case session.account of
                Just a ->
                    { session | route = route }

                Nothing ->
                    { session | route = SignInRoute }

        InValid ->
            { session | route = SignInRoute }

        Verifying ->
            { session | route = SignInRoute }


fromFirebaseAuth firebaseAuthModel =
    case firebaseAuthModel.status of
        Firebase.Auth.Verifying ->
            { init | status = Verifying }

        Firebase.Auth.NoAuth ->
            { init | status = InValid }

        Firebase.Auth.Auth ->
            let
                (account, status) =
                    case firebaseAuthModel.user of
                        Just u ->
                            (Just (Account u.email),Valid)
                        Nothing ->
                            (Nothing, InValid)
            in
                setRoute { init
                                 | status = status
                                 , account = account
                } CustomersRoute
