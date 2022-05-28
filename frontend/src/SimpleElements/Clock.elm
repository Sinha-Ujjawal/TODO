module SimpleElements.Clock exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Svg
import Svg.Attributes
import Task
import Time



-- Model


type alias Model =
    { time : Time.Posix, zone : Time.Zone, show : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Time.millisToPosix 0
      , zone = Time.utc
      , show = False
      }
    , Task.perform AdjustTimeZone Time.here
    )



-- Update


type Msg
    = UpdateTime Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTime newTime ->
            ( { model | time = newTime, show = True }, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )



-- View


atleastTwoDigits : Int -> String
atleastTwoDigits n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


viewDigital : Model -> Html Msg
viewDigital model =
    let
        hour =
            atleastTwoDigits (Time.toHour model.zone model.time)

        mins =
            atleastTwoDigits (Time.toMinute model.zone model.time)

        secs =
            atleastTwoDigits (Time.toSecond model.zone model.time)
    in
    Html.span []
        [ Html.text hour
        , Html.text ":"
        , Html.text mins
        , Html.text ":"
        , Html.text secs
        ]


drawCircle : Float -> Float -> Float -> Svg.Svg Msg
drawCircle cx cy r =
    let
        ( cxStr, cyStr, rStr ) =
            ( String.fromFloat cx, String.fromFloat cy, String.fromFloat r )
    in
    Svg.circle
        [ Svg.Attributes.cx cxStr
        , Svg.Attributes.cy cyStr
        , Svg.Attributes.r rStr
        , Svg.Attributes.fill "#000000"
        ]
        []


drawHand : Float -> Float -> Float -> Float -> String -> Float -> Svg.Svg Msg
drawHand cx cy length strokeWidth color turns =
    let
        angle =
            2 * pi * (turns - 0.25)

        handX =
            String.fromFloat (cx + length * cos angle)

        handY =
            String.fromFloat (cy + length * sin angle)

        ( cxStr, cyStr ) =
            ( String.fromFloat cx, String.fromFloat cy )

        strokeWidthStr =
            String.fromFloat strokeWidth
    in
    Svg.line
        [ Svg.Attributes.x1 cxStr
        , Svg.Attributes.y1 cyStr
        , Svg.Attributes.x2 handX
        , Svg.Attributes.y2 handY
        , Svg.Attributes.stroke color
        , Svg.Attributes.strokeWidth strokeWidthStr
        , Svg.Attributes.strokeLinecap "round"
        ]
        []


viewAnalog : Model -> Html Msg
viewAnalog model =
    let
        ( cx, cy, r ) =
            ( 50, 50, 45 )

        hour =
            Time.toHour model.zone model.time

        mins =
            Time.toMinute model.zone model.time

        secs =
            Time.toSecond model.zone model.time
    in
    Svg.svg [ Svg.Attributes.viewBox "0 0 100 100", Svg.Attributes.width "500px" ]
        [ drawCircle cx cy r
        , drawHand cx cy 30 2 "#154a01" (toFloat hour / 12)
        , drawHand cx cy 40 1 "#023963" (toFloat mins / 60)
        , drawHand cx cy 42 0.5 "#730b03" (toFloat secs / 60)
        ]


view : Model -> Html Msg
view model =
    if model.show then
        Html.div
            [ Html.Attributes.style "width" "800px"
            , Html.Attributes.style "margin" "0 auto"
            ]
            [ viewAnalog model, viewDigital model ]

    else
        Html.div [] []



-- Subs


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 UpdateTime


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
