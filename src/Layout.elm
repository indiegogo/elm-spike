module Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Ribbon exposing (defaultConfig)
import Css
import Css.Colors
import Html.Styled as St
import Html.Styled.Attributes as Sa


bannerConfig msg width =
    ({ defaultConfig | endBgColor = Css.Colors.maroon, skewColor = Css.Colors.gray, messageBorderColor = Css.Colors.silver, mainBgColor = Css.Colors.white, width = width, message = msg })




userRibbonStyle =
    style [
         ("width", "400px")
         ,("margin-right","-120px")
        ]
userRibbon =
    div [ userRibbonStyle]
        [ Ribbon.ribbon_left (bannerConfig "Welcome User Banner" 500) |> St.toUnstyled
        ]

tastyCodeRibbonStyle =
    style [
         ("width", "500px")
         ,("margin-left","-25px")
        ]

tastyCodeRibbon =
    div [ tastyCodeRibbonStyle] [
    Ribbon.ribbon_right
        (bannerConfig "Tasty Code Cakes Banner" 300) |> St.toUnstyled
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
          ,("padding", "10px")
        ]


headerRowStyle =
    style
        [ ( "display", "flex" )
        , ( "width", "100%" )
        , ( "justify-content", "flex-start" )
        , ( "align-items", "flex-start")
        , ("padding", "2px")
        ]


navStyle =
    style
        [ ( "display", "flex" )
        , ( "width", "100%" )
        , ( "justify-content", "flex-start" )
        , ( "align-items", "flex-start")
        ]


sHeader links =
    header [ headerStyle ]
        [ sTitle
        , tastyCodeRibbon
        , sLinks links
        ]


linkStyle =
    style
        [ ( "padding", "5px" )
        , ( "margin", "5px" )
        , ( "font-size", "18px")
        ]


sLinks links =
    div [ headerRowStyle ]
        [ nav [ navStyle ] (List.map (\l -> div [ linkStyle ] [ l ]) links)
        ]

titleStlye =
    style [
         ("justify-content", "space-between")
        ]
sTitle =
    div [ headerRowStyle, titleStlye ]
        [ span [] [ (img [ src "assets/syntax_sugar.png" ] []) ]
        , userRibbon
        ]


view2 body links =
    div [ containerStyle ]
        [ (sHeader links)
        ,  body
        ]
