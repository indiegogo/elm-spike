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
import Customers.Grid as CustomersView
import Customers.DetailList as CustomersDetailView
import SignIn as SignInView exposing (Msg(FireAuth))
import Msg exposing (Msg(..))
import Routing exposing (Route(..))


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
            page model
    in
        div [ containerStyle ]
            [ (sHeader (tabLinks model.session.account) model.session.account)
            , currentView
            ]


page model =
    case model.session.route of
        SignInRoute ->
            (.signInModel >> SignInView.view >> Html.map SignInPage) model

        CustomersRoute ->
            (CustomersView.view model)

        CustomerDetailRoute id ->
            (.detailsModel >> CustomersDetailView.view >> Html.map CustomersDetailListPage) model

        DBTestRoute ->
            (.dbModel >> FirebaseDB.view >> Html.map FirebaseDBPage) model

        OrdersRoute ->
            (.ordersModel >> EmptyView.view >> Html.map EmptyPage) model

        InventoryRoute ->
            (.inventoryModel >> EmptyView.view >> Html.map EmptyPage) model

        NotFoundRoute ->
            e404 model


tabSet =
    [ ( 0, "SignIn", SignInRoute) 
    , ( 1, "Customers", CustomersRoute)
    , ( 1, "Inventory", InventoryRoute)
    , ( 1, "DB Test", DBTestRoute)
    ]


tabNames =
    ( tabSet |> List.map (\( _, x, _) -> text x), [] )


tabLinks model =
    case model of
        Nothing ->
            []

        Just account ->
            (List.map
                (\( _, name, msg) ->
                    Html.a [ onClick (ChangeRoute msg) ] [ text name ]
                )
                (List.filter (\( i, _, _ ) -> i == 1) tabSet)
            )


