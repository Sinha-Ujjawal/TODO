module SimpleElements.Counter exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)



-- Model


type alias Model =
    { counter : Int
    }


init : Model
init =
     { counter = 0 }



-- Update


type Msg
    = CountUp
    | CountDown


update : Msg -> Model -> Model
update msg model =
    case msg of
        CountUp ->
            { model | counter = model.counter + 1}

        CountDown ->
            { model | counter = model.counter - 1 }



-- View


showCount : Model -> Html Msg
showCount model =
    text (String.fromInt model.counter)


countUpButton : Html Msg
countUpButton =
    button [onClick CountUp] [ text "+" ]


countDownButton : Html Msg
countDownButton =
    button [onClick CountDown] [ text "-" ]


view : Model -> Html Msg
view model =
    div []
        [ showCount model
        , countUpButton
        , countDownButton
        ]

main : Program () Model Msg
main =
    Browser.sandbox { init = init
                    , update = update
                    , view = view
                    }
