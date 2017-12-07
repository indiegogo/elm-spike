module Layout exposing (..)

import Array
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ribbon exposing (defaultConfig)
import Css.Colors
import Html.Styled as St
import Empty as EmptyView
import Customers as CustomersView
import SignIn as SignInView exposing (Msg(FireAuth))
import Msg exposing (Msg(..))


-- i think importing SignIn's Child Module in Layout is a bad smell for isolation / encapsulation

import Firebase.Auth as Auth


-- see exposing in FirebaseAuth for how union type is exposed

import Firebase.DB as FirebaseDB


bannerConfig msg width =
    ({ defaultConfig | endBgColor = Css.Colors.maroon, skewColor = Css.Colors.gray, messageBorderColor = Css.Colors.silver, mainBgColor = Css.Colors.white, width = width, message = msg })


userRibbonStyle =
    style
        [ ( "width", "400px" )
        , ( "margin-right", "-120px" )
        ]


userRibbon model =
    case model of
        Just account ->
            div [ userRibbonStyle ]
                [ Ribbon.ribbon_left (bannerConfig ("Welcome " ++ account.username) 500) |> St.toUnstyled
                , a [ onClick (SignInPage (FireAuth (Auth.UI Auth.Logout))) ] [ text "Sign Out" ]
                ]

        Nothing ->
            span [] []


tastyCodeRibbonStyle =
    style
        [ ( "width", "500px" )
        , ( "margin-left", "-25px" )
        ]


tastyCodeRibbon =
    div [ tastyCodeRibbonStyle ]
        [ Ribbon.ribbon_right
            (bannerConfig "TASTY CODE CAKES ON THE INTERWEBS" 800)
            |> St.toUnstyled
        ]



{- tasty code ribbon stuff
   Options.css "margin-top" "25px", Options.css "margin-left" "-106px"
-}


containerStyle =
    style
        [ ( "display", "grid" )
        ]


headerStyle =
    style
        [ ( "background-color", "orange" )
        , ( "padding", "10px" )
        ]


headerRowStyle =
    style
        [ ( "display", "flex" )
        , ( "width", "100%" )
        , ( "justify-content", "flex-start" )
        , ( "align-items", "flex-start" )
        , ( "padding", "2px" )
        ]


navStyle =
    style
        [ ( "display", "flex" )
        , ( "width", "100%" )
        , ( "justify-content", "flex-start" )
        , ( "align-items", "flex-start" )
        ]


sHeader links model =
    header [ headerStyle ]
        [ sTitle model
        , tastyCodeRibbon
        , sLinks links
        ]


linkStyle =
    style
        [ ( "padding", "5px" )
        , ( "margin", "5px" )
        , ( "font-size", "18px" )
        ]


sLinks links =
    let
        leftLinks =
            (List.map (\l -> div [ linkStyle ] [ l ]) links)

        rightLinks =
            [ i [ linkStyle, class "material-icons" ] [ text "add_circle" ]
            , i [ linkStyle, class "material-icons" ] [ text "settings" ]
            , i [ linkStyle, class "material-icons" ] [ text "search" ]
            ]

        navLinks =
            List.concat [ leftLinks, [ div [ class "mdl-layout-spacer" ] [] ], rightLinks ]
    in
        div [ headerRowStyle ]
            [ nav [ navStyle ] navLinks
            ]


titleStlye =
    style
        [ ( "justify-content", "space-between" )
        ]


sTitle model =
    div [ headerRowStyle, titleStlye ]
        [ span [] [ (img [ src "/assets/syntax_sugar.png" ] []) ]
        , userRibbon model
        ]


e404 _ =
    div []
        [ Html.h1 [] [ text "404 u" ]
        ]


view model =
    let
        currentView =
            (Array.get model.session.pageIndex tabViews |> Maybe.withDefault e404) model
    in
        div [ containerStyle ]
            [ (sHeader (tabLinks model.session.account) model.session.account)
            , currentView
            ]


tabSet =
    [ ( 0, "SignIn", "signIn", .signInModel >> SignInView.view >> Html.map SignInPage )
    , ( 1, "Customers", "cust", .customersModel >> CustomersView.view >> Html.map CustomersPage )
    , ( 1, "Orders", "ord", .ordersModel >> EmptyView.view >> Html.map EmptyPage )
    , ( 1, "Inventory", "inv", .inventoryModel >> EmptyView.view >> Html.map EmptyPage )
    , ( 1, "DB Test", "db", .dbModel >> FirebaseDB.view >> Html.map FirebaseDBPage )
    ]


tabViews =
    List.map (\( _, _, _, v ) -> v) tabSet |> Array.fromList


tabNames =
    ( tabSet |> List.map (\( _, x, _, _ ) -> text x), [] )


urlTabs =
    List.indexedMap (\idx ( _, _, u, _ ) -> ( u, idx )) tabSet |> Dict.fromList


tabUrls =
    List.map (\( _, _, u, _ ) -> u) tabSet |> Array.fromList


tabLinks model =
    case model of
        Nothing ->
            []

        Just a ->
            (List.map
                (\( _, name, href_, _ ) ->
                    Html.a [ href ("#" ++ href_) ] [ text name ]
                )
                (List.filter (\( i, _, _, _ ) -> i == 1) tabSet)
            )


urlOf model =
    "#" ++ (Array.get model.session.pageIndex tabUrls |> Maybe.withDefault "")
