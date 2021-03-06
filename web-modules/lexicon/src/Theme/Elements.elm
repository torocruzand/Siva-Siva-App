module Theme.Elements exposing (bodyStyle, fontAwesomeIcon, headerStyle, headerTitle, icon, listHeader, navButton, searchBox, searchHeader, seeAlso, takeFurther, toolbarButton, wordDefinitionIcon)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (classList, css, value, id, placeholder)
import Html.Styled.Events exposing (..)
import Theme.Colors exposing (..)
import Json.Decode as Decode



onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Decode.succeed msg
            else
                Decode.fail "not ENTER"
    in
    on "keydown" (Decode.andThen isEnter keyCode)

navButton : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
navButton isCurrentPage =
    let
        bgColor =
            if isCurrentPage then
                theme.button.active

            else
                theme.button.background
    in
    styled button
        [ flex (int 1)
        , margin (px 2)
        , height (px 57)
        , fontSize (px 18)
        , backgroundColor bgColor
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
        , displayFlex
        , flexDirection column
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
                [ fontSize (px 18)
                , fontWeight bold
                , color theme.palette.white
                , textTransform uppercase
                , margin zero
                ]
            ]
            [ text "A Hindu Lexicon" ]
        ]


searchHeader : msg -> Html msg
searchHeader click =
    div
        [ css
            [ textAlign center
            , fontSize (px 18)
            ]
        ]
        [ span
            [ css
                [ color theme.palette.lightBlue
                , display block
                ]
            ]
            [ text "Enter a single word or part of a word" ]
        , span
            [ css
                [ color theme.palette.lightGreen
                , display block
                ]
            , onClick click
            ]
            [ text "Need help?" ]
        ]


searchBox : (String -> msg) -> msg -> String -> Html msg
searchBox changed search query =
    div
        [ css
            [ marginTop (px 10) ]
        ]
        [ input
            [ css
                [ fontSize (px 30)
                , textAlign left
                , borderStyle none
                , backgroundColor (rgb 10 70 80)
                , color theme.palette.white
                , width (pct 80)
                , lineHeight (int 2)
                , paddingRight (px 20)
                ]
            , onInput changed
            , onEnter search
            , value query
            , id "search-box"
            , placeholder "  🔎"
            ]
            []

        ]


listHeader : Html msg
listHeader =
    div
        [ css
            [ textAlign center
            , fontSize (px 18)
            , marginTop (px 20)
            ]
        ]
        [ span
            [ css
                [ color theme.palette.lightBlue
                , display block
                ]
            ]
            [ text "Scroll the results and choose a word!" ]

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


icon : String -> msg -> Html msg
icon name click =
    div
        [ css
            [ color theme.palette.white
            , padding (px 5)
            ]
        , onClick click
        ]
        [ fontAwesomeIcon name "2x" ]


wordDefinitionIcon : msg -> String -> Html msg
wordDefinitionIcon click name =
    div
        [ css
            [ color theme.palette.lightGreen
            , padding (px 5)
            ]
        , onClick click
        ]
        [ fontAwesomeIcon name "lg" ]


seeAlso : msg -> String -> Html msg
seeAlso click word =
    if String.length word == 0 then
        span [] []

    else
        button
            [ css
                [ backgroundColor theme.button.background
                , color theme.palette.white
                , borderRadius (px 8)
                , padding (px 10)
                , fontSize (px 20)
                , margin (px 10)
                , borderStyle none
                ]
            , onClick click
            ]
            [ text word ]


takeFurther : Html msg
takeFurther =
    div
        [ css
            [ textAlign center
            , fontSize (px 18)
            , marginTop (px 20)
            ]
        ]
        [ span
            [ css
                [ color theme.palette.lightBlue
                , display block
                ]
            ]
            [ text "Go for a word adventure:" ]
        ]
