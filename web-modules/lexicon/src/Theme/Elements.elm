module Theme.Elements exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (classList, css)
import Theme.Colors exposing (..)


navButton : List (Attribute msg) -> List (Html msg) -> Html msg
navButton =
    styled button
        [ flex (int 1)
        , margin (px 2)
        , height (px 57)
        , fontSize (px 18)
        , backgroundColor theme.button.background
        , borderStyle none
        , color theme.button.text
        , hover
            [ backgroundColor theme.button.active
            ]
        ]


toolbarButton : List (Attribute msg) -> List (Html msg) -> Html msg
toolbarButton =
    styled button
        [ color theme.palette.white
        ]


bodyStyle : Style
bodyStyle =
    Css.batch
        [ backgroundColor theme.palette.darkGreen
        , height (pct 100)
        , minHeight (pct 100)
        ]


headerStyle : Style
headerStyle =
    Css.batch
        [ position fixed
        , top zero
        , width (pct 100)
        ]


headerTitle : Html msg
headerTitle =
    div
        [ css
            [ textAlign center
            , backgroundColor (hex "#0a4650")
            , height (px 43)
            , displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent center
            ]
        ]
        [ h1
            [ css
                [ fontSize (pt 16)
                , color theme.palette.cream
                , textTransform uppercase
                , margin zero
                ]
            ]
            [ text "A Hindu World of Adventure" ]
        ]


fontAwesomeIcon : String -> String -> Html msg
fontAwesomeIcon name size =
    i
        [ classList
            [ ( "fa-" ++ name, True )
            , ( "fa", True )
            , ( "fa-" ++ size, True )
            ]
        ]
        []


icon : String -> Html msg
icon name =
    div
        [ css
            [ color theme.palette.white
            , padding (px 5)
            ]
        ]
        [ fontAwesomeIcon name "2x" ]


wordDefinitionIcon : String -> Html msg
wordDefinitionIcon name =
    div
        [ css
            [ color theme.palette.greenIcon
            , padding (px 5)
            ]
        ]
        [ fontAwesomeIcon name "lg" ]