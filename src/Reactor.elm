module Reactor exposing (update, view, init, subscriptions)

import Html exposing (div, text, a, h1)
import Html.Attributes exposing (href, style)
import Msg exposing (..)
import Debug as D exposing (log)
import Route
import Pages.Home
import Views.Home as HomeView exposing (view)
import Material
import Material.Options as Options
import Material.Scheme
import Material.Color as MColor
import Material.Layout as Layout


type PageApp
    = BlankApp
    | NotFound
    | HomeApp Pages.Home.Model


type PageState
    = Loaded PageApp
    | LoadingFrom PageApp


type alias Model =
    { pageState : PageState
    , mdl : Material.Model
    }



--
-- Init establishes the basic data structure.
--


init location =
    let
        b =
            D.log "location" location

        c =
            D.log "function" "init"
    in
        (setRoute
            (Route.fromLocation location)
            { pageState = Loaded BlankApp
            , mdl = Material.model
            }
        )



-- Update is a triggered by a Msg which represents
-- a particular side-effect generated by an actor
--


update msg model =
    let
        a =
            D.log "model" model

        b =
            D.log "msg" msg

        c =
            D.log "update"
    in
        case msg of
            SetRoute route ->
                setRoute route model

            Mdl msg_ ->
                Material.update Mdl msg_ model


viewBlank =
    a [ href "#blank" ] [ text "Mu" ]


viewHome =
    a [ href "#home" ] [ text "Home" ]


viewNotFound =
    a [ href "#aouaoeuaoeuaoeu123" ] [ text "NotFoundError" ]



--
-- view is invoked by updates to the model
--


navLinks =
    [ div []
        [ viewBlank
        , text " | "
        , viewHome
        , text " | "
        , viewNotFound
        ]
    ]


view model =
    let
        headerBuilder html =
            div [ style [ ( "display", "flex" ), ( "position", "absolute" ), ( "top", "0" ), ( "bottom", "0" ), ( "left", "0" ), ( "right", "0" ) ] ]
                [ div [ style [ ( "font-size", "3em" ), ( "margin", "auto" ) ] ] (List.append [ html ] navLinks)
                ]
        stylesheet =
            Options.stylesheet """
            """
        layout main =
            Layout.render
                Mdl
                model.mdl
                [ Layout.fixedHeader
                ]
                { header =
                    [ h1
                        [ style [ ( "padding", "2rem" ) , ("color", "#fff")]
                        ]
                        [ text "Syntax Sugar"
                        ]
                    ]
                , drawer = []
                , tabs = ( [], [] )
                , main = [ stylesheet ,main ]
                }
               
    in
        case model.pageState of
            Loaded page ->
                case page of
                    HomeApp model ->
                        layout (headerBuilder (HomeView.view model))

                    BlankApp ->
                        headerBuilder (text "This is the Page that represents non-thing => mu")

                    NotFound ->
                        headerBuilder (text "This is the Not Found html page")

            LoadingFrom page ->
                headerBuilder (text ("Transition from'" ++ (toString page) ++ "'"))


subscriptions model =
    Sub.none


setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | pageState = Loaded NotFound }, Cmd.none )

        Just (Route.HomeRoute) ->
            ( { model | pageState = Loaded (HomeApp Pages.Home.init) }, Cmd.none )

        Just (Route.BlankRoute) ->
            ( { model | pageState = Loaded BlankApp }, Cmd.none )
