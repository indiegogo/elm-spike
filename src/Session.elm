module Session
    exposing
        ( SessionStatus(..)
        , Account
        , Session
        , init
        , setPageIndex
        , fromFirebaseAuth
        )

import Firebase.Auth exposing (AuthStatus)


type SessionStatus
    = InValid
    | Verifying
    | Valid


type alias Account =
    { username : String
    }


type alias Session =
    { pageIndex : Int
    , account : Maybe Account
    , status : SessionStatus
    }


init : Session
init =
    Session 0 Nothing InValid


setPageIndex session index =
    case session.status of
        Valid ->
            case session.account of
                Just a ->
                    { session | pageIndex = index }

                Nothing ->
                    { session | pageIndex = 0 }

        InValid ->
            { session | pageIndex = 0 }

        Verifying ->
            { session | pageIndex = 0 }


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
                setPageIndex { init
                                 | status = status
                                 , account = account
                } 1
