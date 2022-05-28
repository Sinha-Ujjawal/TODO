module SimpleElements.Dice exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Random
import Time



-- Model


type DieSide
    = One
    | Two
    | Three
    | Four
    | Five
    | Six


type alias Model =
    { dieSide : DieSide }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { dieSide = One }, Cmd.none )



-- View


dieSideRepr : DieSide -> String
dieSideRepr dieSide =
    -- ⚀⚁⚂⚃⚄⚅
    case dieSide of
        One ->
            "⚀"

        Two ->
            "⚁"

        Three ->
            "⚂"

        Four ->
            "⚃"

        Five ->
            "⚄"

        Six ->
            "⚅"


view : Model -> Html Msg
view { dieSide } =
    Html.div [ Html.Attributes.style "font-size" "12em" ]
        [ Html.text (dieSideRepr dieSide) ]



-- Update


type Msg
    = Roll
    | Change DieSide


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model, Random.generate Change roll )

        Change newDieSide ->
            ( { model | dieSide = newDieSide }, Cmd.none )


roll : Random.Generator DieSide
roll =
    Random.uniform One [ Two, Three, Four, Five, Six ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 (\_ -> Roll)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
