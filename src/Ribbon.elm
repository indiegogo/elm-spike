module Ribbon exposing (example, ribbon_left, ribbon_right, ribbon_full, defaultConfig, main)

import Css exposing (..)
import Css.Colors
import Html exposing (program)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as SA exposing (css, href, src, styled)
import List exposing (concat)


type alias Config =
    { width : Int
    , height : Int
    , skewColor : Css.Color
    , mainBgColor : Css.Color
    , endBgColor : Css.Color
    , messageBorderColor : Css.Color
    , message : String
    }


main =
    Html.program
        { view = \m -> (example m.message) |> H.toUnstyled
        , update = update
        , init = ( { message = "I'm the Example Ribbon" }, Cmd.none )
        , subscriptions = (always Sub.none)
        }


update msg model =
    ( model, Cmd.none )


example msg =
    ribbon_full { defaultConfig | message = msg }


builder config fragments =
    (H.div [ (ribbon_container config) ] fragments)


ribbon_full config =
    builder config (List.concat [ leftFragment config, mainFragment config, rightFragment config ])


ribbon_left config =
    builder config
        (List.concat
            [ leftFragment config
            , mainFragment config
            ]
        )


ribbon_right config =
    builder config
        (List.concat
            [ mainFragment config
            , rightFragment config
            ]
        )


leftFragment config =
    [ H.div [ (ribbon_back_left config) ] (arrowFragmentLeft config)
    , H.div [ (ribbon_skew_left config) ] []
    ]


rightFragment config =
    [ H.div [ (ribbon_skew_right config) ] []
    , H.div [ (ribbon_back_right config) ] (arrowFragmentRight config)
    ]


arrowFragmentLeft config =
    [ H.div [ (ribbon_arrow_left_top config) ] []
    , H.div [ (ribbon_arrow_left_bottom config) ] []
    ]


arrowFragmentRight config =
    [ H.div [ (ribbon_arrow_right_top config) ] []
    , H.div [ (ribbon_arrow_right_bottom config) ] []
    ]


mainFragment config =
    [ H.div [ (ribbon_middle config) ]
        [ H.div [ (ribbon_middle_message config) ]
            [ H.text config.message
            ]
        ]
    ]



{-
   right: -30px;

   border-bottom: 25px solid transparent;
   border-top: 0px solid transparent;
   border-left: 30px solid #1199a9;
   border-right: none;

   top: 0px;

   height: 25px !important;
   position: absolute;
   z-index: 2;
   width: 0;

   box-sizing: border-box;

-}


ribbon_arrow_right_top config =
    SA.css
        [ Css.batch
            [ right (px -29)
            , top (px 0)
            , width (px 0)
            , important (height (px 25))
            , borderBottom3 (px 25) solid transparent
            , borderTop3 (px 0) solid transparent
            , borderLeft3 (px 30) solid config.endBgColor
            , borderRight (px 0)
            , position absolute
            , zIndex (int 2)
            , boxSizing borderBox
            ]
        ]



{-
   right: -30px;

   border-top: 25px solid transparent;
   border-bottom: 0px solid transparent;
   border-left: 30px solid #1199a9;
   border-right: none;

   top: 25px;

   height: 25px !important;
   position: absolute;
   z-index: 2;
   width: 0;

   box-sizing: border-box;
-}


ribbon_arrow_right_bottom config =
    SA.css
        [ Css.batch
            [ right (px -29)
            , top (px 25)
            , width (px 0)
            , borderTop3 (px 25) solid transparent
            , borderBottom3 (px 0) solid transparent
            , borderLeft3 (px 30) solid config.endBgColor
            , borderRight (px 0)
            , important (height (px 25))
            , position absolute
            , zIndex (int 2)
            , boxSizing borderBox
            ]
        ]



{-
   right: 0;
   background: #1199a9;
   position: absolute;
   width: 8%;
   top: 12px;
   height: 50px;

   box-sizing: border-box;

-}


ribbon_back_right config =
    SA.css
        [ Css.batch
            [ right (px 0)
            , backgroundColor config.endBgColor
            , position absolute
            , width (pct 8)
            , top (px 12)
            , height (px 50)
            , boxSizing borderBox
            ]
        ]



{-
   right: 5%;
   transform: skew(00deg, -20deg);
   background: #ff6b2a;
   position: absolute;
   width: 3%;
   top: 6px;
   z-index: 5;
   height: 50px;

   box-sizing: border-box;
-}


ribbon_skew_right config =
    SA.css
        [ Css.batch
            [ right (pct 5)
            , transform (skew2 (deg 0) (deg -20))
            , backgroundColor config.skewColor
            , position absolute
            , width (pct 3)
            , top (px 6)
            , zIndex (int 5)
            , height (px 50)
            , boxSizing borderBox
            ]
        ]



{-
   left: -30px;
   top: 0px;
   border-top: 0px solid transparent;
   border-bottom: 25px solid transparent;
   border-right: 30px solid #1199a9;
   height: 25px !important;
   position: absolute;
   z-index: 2;
   width: 0;
   box-sizing: border-box;
-}


ribbon_arrow_left_top config =
    SA.css
        [ Css.batch
            [ left (px -29)
            , top (px 0)
            , borderTop3 (px 0) solid transparent
            , borderBottom3 (px 25) solid transparent
            , borderRight3 (px 30) solid config.endBgColor
            , important (height (px 25))
            , position absolute
            , zIndex (int 2)
            , boxSizing borderBox
            ]
        ]



{-
   left: -30px;
   top: 25px;
   border-top: 25px solid transparent;
   border-bottom: 0px solid transparent;
   border-right: 30px solid #1199a9;
   height: 25px !important;
   position: absolute;
   z-index: 2;
   width: 0;
   box-sizing: border-box;
-}


ribbon_arrow_left_bottom config =
    SA.css
        [ Css.batch
            [ left (px -29)
            , top (px 25)
            , borderTop3 (px 25) solid transparent
            , borderBottom3 (px 0) solid transparent
            , borderRight3 (px 30) solid config.endBgColor
            , position absolute
            , zIndex (int 2)
            , width (px 0)
            , boxSizing borderBox
            ]
        ]



{-

   left: 0;
   background: #1199a9;
   position: absolute;
   width: 8%;
   top: 12px;
   height: 50px;

   box-sizing: border-box;

-}


ribbon_back_left config =
    SA.css
        [ Css.batch
            [ left (px 0)
            , backgroundColor config.endBgColor
            , position absolute
            , width (pct 8)
            , top (px 12)
            , height (px 50)
            , boxSizing borderBox
            ]
        ]



{-
   left: 5%;
   transform: skew(00deg, 20deg);
   background: #ff6b2a;
   position: absolute;
   width: 3%;
   top: 6px;
   z-index: 5;
   height: 50px;

   box-sizing: border-box;
-}


ribbon_skew_left config =
    SA.css
        [ Css.batch
            [ left (pct 5)
            , transform (skew2 (deg 0) (deg 20))
            , backgroundColor config.skewColor
            , position absolute
            , width (pct 3)
            , top (px 6)
            , zIndex (int 5)
            , height (px 50)
            , boxSizing borderBox
            ]
        ]



{-
   background: #0fadc0;
   position: relative;
   display: block;
   width: 90%;
   left: 50%;
   top: 0;
   padding: 5px;
   margin-left: -45%;
   z-index: 10;
   height: 50px;

   box-sizing: border-box;
-}


ribbon_middle config =
    SA.css
        [ Css.batch
            [ backgroundColor config.mainBgColor
            , position relative
            , width (pct 90)
            , left (pct 50)
            , top (pct 0)
            , padding (px 5)
            , marginLeft (pct -45)
            , zIndex (int 10)
            , height (px 50)
            , boxSizing borderBox
            ]
        ]



{-
   border: 1px dashed rgba(255, 255, 255, 0.5);
   height: 40px;
   line-height: 40px;
   text-align: center;

   box-sizing: border-box;
-}


ribbon_middle_message config =
    SA.css
        [ Css.batch
            [ border3 (px 1) dashed config.messageBorderColor
            , height (px 40)
            , lineHeight (px 40)
            , textAlign center
            , boxSizing borderBox
            ]
        ]



{-

   width: 80%;
   max-width: 300px;
   height: 80px;
   margin: 40px auto;
   position: relative;


   box-sizing: border-box;
-}


ribbon_container config =
    SA.css
        [ Css.batch
            [ width (pct 80)
            , maxWidth (px config.width)
            , height (px 80)
            , position relative
            , boxSizing borderBox
            ]
        ]


defaultConfig =
    { width = 1000, height = 50, skewColor = (hex "556B2A"), mainBgColor = (hex "55adc0"), endBgColor = (hex "5599a9"), messageBorderColor = Css.Colors.black, message = "" }


css =
    """

@media all and (max-width: 1020px) {
  .igg-ribbon__skew.igg-ribbon__left {
    left: 5%;
    transform: skew(00deg,25deg);
  }

  .igg-ribbon__skew.igg-ribbon__right {
    right: 5%;
    transform: skew(00deg,-25deg);
  }
}

@media all and (max-width: 680px) {
  .igg-ribbon__skew.igg-ribbon__left {
    left: 5%;
    transform: skew(00deg,30deg);
  }

  .igg-ribbon__skew.igg-ribbon__right {
    right: 5%;
    transform: skew(00deg,-30deg);
  }
}

@media all and (max-width: 460px) {
  .igg-ribbon__skew.igg-ribbon__left {
    left: 5%;
    transform: skew(00deg,40deg);
  }
  .igg-ribbon__skew.igg-ribbon__right {
    right: 5%;
    transform: skew(00deg,-40deg);
  }
}
"""
