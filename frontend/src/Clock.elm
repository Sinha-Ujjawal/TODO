module Clock exposing (main)

import Browser
import Html exposing (Html, span, text)
import Task
import Time



-- Model


type alias Model =
    { time : Time.Posix, zone : Time.Zone }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Time.millisToPosix 0, zone = Time.utc }, Task.perform AdjustTimeZone Time.here )



-- Update


type Msg
    = UpdateTime Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTime newTime ->
            ( { model | time = newTime }, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )



-- View


atleastTwoDigits : Int -> String
atleastTwoDigits n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


view : Model -> Html Msg
view model =
    let
        hour =
            atleastTwoDigits (Time.toHour model.zone model.time)

        mins =
            atleastTwoDigits (Time.toMinute model.zone model.time)

        secs =
            atleastTwoDigits (Time.toSecond model.zone model.time)
    in
    span []
        [ text hour
        , text ":"
        , text mins
        , text ":"
        , text secs
        ]



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
