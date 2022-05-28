module Todo exposing (main)

import Api
import Browser
import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Events
import Time



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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { baseUrl = "http://localhost:4000/api"
      , todos = []
      , newTodoMaybe = Nothing
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


view : Model -> Html Msg
view { todos, newTodoMaybe } =
    case newTodoMaybe of
        Just newTodo ->
            let
                addButtonDisabled =
                    newTodo.title == "" || newTodo.detail == ""
            in
            Html.div []
                [ Html.div [] (List.map renderTodo todos)
                , Html.form
                    [ Html.Events.onSubmit (AddNewTodo newTodo) ]
                    [ Html.div [] [ Html.input [ Html.Attributes.value newTodo.title, Html.Events.onInput (UpdateTitleNewTodo newTodo) ] [] ]
                    , Html.div [] [ Html.textarea [ Html.Attributes.value newTodo.detail, Html.Events.onInput (UpdateDetailNewTodo newTodo) ] [] ]
                    , Html.button [ Html.Attributes.type_ "Submit", Html.Attributes.disabled addButtonDisabled ] [ Html.text "Add" ]
                    ]
                , Html.button [ Html.Events.onClick (DiscardNewTodo newTodo) ] [ Html.text "Discard" ]
                ]

        Nothing ->
            Html.div []
                [ Html.div [] (List.map renderTodo todos)
                , Html.button [ Html.Events.onClick NewTodoForm ] [ Html.text "Create New Todo" ]
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
    | NewTodoAdded Api.Todo
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadTodos ->
            ( model, getTodos model.baseUrl )

        UpdateTodos newTodos ->
            ( { model | todos = newTodos }, Cmd.none )

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

        NewTodoAdded newTodo ->
            ( { model | todos = model.todos ++ [ newTodo ] }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


getTodos : String -> Cmd Msg
getTodos baseUrl =
    let
        convert : Api.TodosResult -> Msg
        convert todoResult =
            case todoResult of
                Api.GotTodos (Ok todos) ->
                    UpdateTodos todos

                _ ->
                    UpdateTodos []
    in
    Api.getTodos baseUrl
        |> Cmd.map convert


addTodo : String -> String -> String -> Cmd Msg
addTodo baseUrl title detail =
    let
        convert : Api.TodosResult -> Msg
        convert todoResult =
            case todoResult of
                Api.GotTodo (Ok todo) ->
                    NewTodoAdded todo

                _ ->
                    NoOp
    in
    Api.addTodo baseUrl title detail
        |> Cmd.map convert



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 5000 (\_ -> LoadTodos)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
