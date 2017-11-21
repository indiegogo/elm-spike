module Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Ribbon exposing(defaultConfig)

import Css
import Css.Colors
import Html.Styled as St
import Html.Styled.Attributes as Sa

bannerConfig msg width=
        ({ defaultConfig | endBgColor = Css.Colors.maroon, skewColor = Css.Colors.gray, messageBorderColor = Css.Colors.silver, mainBgColor = Css.Colors.white, width = width, message = msg })

userRibbon =
    St.div [Sa.css [Css.marginRight (Css.px -113), Css.width (Css.px 300) ] ] [
     Ribbon.ribbon_left ( bannerConfig "Welcome User Banner" 300) 
    ]

tastyCodeRibbon =
    Ribbon.ribbon_right
        (bannerConfig "Tasty Code Cakes Banner" 300)
                    {- tasty code ribbon stuff
                      Options.css "margin-top" "25px", Options.css "margin-left" "-106px" -}


view2 body links =
    let styledRibbons =
        St.div [] [userRibbon, tastyCodeRibbon] |> St.toUnstyled
    in
    div [ ]
        [ nav []  (List.concat [[styledRibbons], links])
         , div [] body
        ]

