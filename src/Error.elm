module Error exposing (..)



type PageError =
    PageError PageErrorKind PageErrorModel

type PageErrorKind
    = Loading

type alias PageErrorModel      =
    {
        errorMessage: String
    }


makeLoadingError eMessage =
    PageError Loading { errorMessage = eMessage}
