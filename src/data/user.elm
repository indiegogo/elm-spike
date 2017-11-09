module Data.User exposing(User)

type alias User =
    {
        authToken: String,
        email: String
    }
