module Todo exposing (main)

import Api
import Browser
import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Events
import HttpErrorHelper exposing (httpErrToString)



-- Model


type alias NewTodo =
    { title : String, detail : String }


emptyNewTodo : NewTodo
emptyNewTodo =
    { title = "", detail = "" }


type alias Model =
    { baseUrl : String
    , todos : List Api.Todo
    , newTodoMaybe : Maybe NewTodo
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { baseUrl = "http://localhost:4000/api"
      , todos = []
      , newTodoMaybe = Nothing
      , error = Nothing
      }
    , getTodos "http://localhost:4000/api"
    )



-- View


label : String -> Html Msg
label labelItem =
    Html.label
        [ style "font-size" "12px"
        , style "font-family" "monospace"
        , style "color" "#777777"
        ]
        [ Html.text labelItem ]


renderTodo : Api.Todo -> Html Msg
renderTodo { title, detail } =
    Html.div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "padding" "8px 4px"
        , style "background" "#f4f5f6"
        , style "border-radius" "4px"
        , style "margin" "8px"
        ]
        [ label ("title: " ++ title)
        , label ("detail: " ++ detail)
        ]


showNewTodoForm : Maybe NewTodo -> Html Msg
showNewTodoForm newTodoMaybe =
    case newTodoMaybe of
        Just newTodo ->
            let
                addButtonDisabled =
                    newTodo.title == "" || newTodo.detail == ""
            in
            Html.div []
                [ Html.form
                    [ Html.Events.onSubmit (AddNewTodo newTodo) ]
                    [ Html.div [] [ Html.input [ Html.Attributes.value newTodo.title, Html.Events.onInput (UpdateTitleNewTodo newTodo) ] [] ]
                    , Html.div [] [ Html.textarea [ Html.Attributes.value newTodo.detail, Html.Events.onInput (UpdateDetailNewTodo newTodo) ] [] ]
                    , Html.button [ Html.Attributes.type_ "Submit", Html.Attributes.disabled addButtonDisabled ] [ Html.text "Add" ]
                    ]
                , Html.button [ Html.Events.onClick (DiscardNewTodo newTodo) ] [ Html.text "Discard" ]
                ]

        Nothing ->
            Html.div [] [ Html.button [ Html.Events.onClick NewTodoForm ] [ Html.text "Create New Todo" ] ]


viewNormal : Model -> Html Msg
viewNormal { todos, newTodoMaybe } =
    Html.div []
        [ Html.div [] (List.map renderTodo todos)
        , showNewTodoForm newTodoMaybe
        , Html.div [] [ Html.button [ Html.Events.onClick LoadTodos ] [ Html.text "Refresh" ] ]
        ]


showError : Model -> Html Msg
showError { error } =
    case error of
        Nothing ->
            Html.text ""

        Just err ->
            Html.div [ style "color" "red" ] [ Html.text ("*" ++ err) ]


view : Model -> Html Msg
view model =
    Html.div []
        [ viewNormal model
        , showError model
        ]



-- Update


type Msg
    = LoadTodos
    | UpdateTodos (List Api.Todo)
    | NewTodoForm
    | AddNewTodo NewTodo
    | DiscardNewTodo NewTodo
    | UpdateTitleNewTodo NewTodo String
    | UpdateDetailNewTodo NewTodo String
    | AppendToTodos Api.Todo
    | Error String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadTodos ->
            ( model, getTodos model.baseUrl )

        UpdateTodos newTodos ->
            ( { model | todos = newTodos, error = Nothing }, Cmd.none )

        NewTodoForm ->
            ( { model | newTodoMaybe = Just emptyNewTodo }, Cmd.none )

        AddNewTodo { title, detail } ->
            ( model, addTodo model.baseUrl title detail )

        DiscardNewTodo _ ->
            ( { model | newTodoMaybe = Nothing }, Cmd.none )

        UpdateTitleNewTodo newTodo title ->
            ( { model | newTodoMaybe = Just { newTodo | title = title } }, Cmd.none )

        UpdateDetailNewTodo newTodo detail ->
            ( { model | newTodoMaybe = Just { newTodo | detail = detail } }, Cmd.none )

        AppendToTodos todo ->
            ( { model | todos = model.todos ++ [ todo ], error = Nothing }, Cmd.none )

        Error err ->
            ( { model | error = Just err }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


getTodos : String -> Cmd Msg
getTodos baseUrl =
    let
        convert : Api.GotTodos -> Msg
        convert todosResult =
            case todosResult of
                Ok todos ->
                    UpdateTodos todos

                Err err ->
                    Error (httpErrToString err)
    in
    Api.getTodos baseUrl
        |> Cmd.map convert


addTodo : String -> String -> String -> Cmd Msg
addTodo baseUrl title detail =
    let
        convert : Api.GotTodo -> Msg
        convert todoResult =
            case todoResult of
                Ok todo ->
                    AppendToTodos todo

                Err err ->
                    Error (httpErrToString err)
    in
    Api.addTodo baseUrl title detail
        |> Cmd.map convert



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
