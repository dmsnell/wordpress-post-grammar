port module Explorer exposing (..)

import Html exposing (code, div, pre, text, textarea)
import Html.Attributes exposing (class, style)
import Html.Attributes.Extra exposing (innerHtml)
import Html.Events exposing (onInput)


port submitPost : String -> Cmd msg


port receiveParse : (String -> msg) -> Sub msg


type Msg
    = UpdateInput String
    | ReceiveParse String


type ParseStatus
    = ParseGood
    | ParseBad


type alias Model =
    { input : String
    , parse : String
    , status : ParseStatus
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput input ->
            ( { model
                | input = input
                , status = ParseBad
              }
            , submitPost input
            )

        ReceiveParse parse ->
            case parse of
                "" ->
                    ( { model | status = ParseBad }, Cmd.none )

                _ ->
                    ( { model | parse = parse, status = ParseGood }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveParse ReceiveParse


statusMessage : ParseStatus -> Html.Html Msg
statusMessage status =
    case status of
        ParseGood ->
            div [ style [ ( "color", "green" ) ] ] [ text "Complete parse" ]

        ParseBad ->
            div [ style [ ( "color", "red" ) ] ] [ text "No valid parse" ]


highlightClass : ParseStatus -> String
highlightClass status =
    case status of
        ParseGood ->
            ""

        ParseBad ->
            "nohighlight"


view : Model -> Html.Html Msg
view { input, parse, status } =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "font-family", "monospace" )
            , ( "font-size", "16px" )
            ]
        ]
        [ div
            [ style
                [ ( "flex", "1 0 0" )
                , ( "min-width", "50%" )
                ]
            ]
            [ textarea
                [ style
                    [ ( "width", "95%" )
                    , ( "height", "100%" )
                    , ( "padding", "1em" )
                    , ( "font-family", "monospace" )
                    , ( "font-size", "16px" )
                    ]
                , onInput UpdateInput
                ]
                [ text input ]
            ]
        , div
            [ style
                [ ( "flex", "1 0 0" )
                ]
            ]
            [ div [] [ statusMessage status ]
            , pre
                [ class <| highlightClass status
                , style
                    [ ( "padding", "1em" )
                    ]
                ]
                [ code [ innerHtml parse ] [] ]
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( Model initialInput "" ParseBad, submitPost initialInput )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


initialInput : String
initialInput =
    """<!-- @block-start not:complete -->
<!-- @block-start type:header -->
<p class="frist-post">First <em>Paragraph</em></p>
<!-- @block-end -->

<!-- @block-start type:main -->

<!-- just a comment -->
<p contentEditable class="test">Paragraph with a <a href="wordpress.com">link</a> in it.</p>

<!-- @block-start type:aside -->
This is a nested aside.

<!-- @block-start type:profile user:hunter02-->
<!-- @block-end -->

<!-- @block-end -->

<!-- @block-end -->"""
