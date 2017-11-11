

module Pages.Home exposing (..)

import Error exposing (makeLoadingError, PageError)
import Task 

type alias Model =
    { name : String
    }


pageName =
    "Welcome Home Page"

init : Model
init =
        Model pageName
