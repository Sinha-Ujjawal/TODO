module Api exposing (Todo, GotTodo, GotTodos, addTodo, getTodos)

import Http
import Json.Decode as D exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E
import Result exposing (Result)


type alias Response a =
    { data : a }


responseDecoder : Decoder a -> Decoder (Response a)
responseDecoder decoder =
    D.succeed Response
        |> required "data" decoder


unwrapResponse : Decoder a -> Decoder a
unwrapResponse decoder =
    decoder
        |> responseDecoder
        |> D.map (\x -> x.data)


type alias Todo =
    { id : Int, title : String, detail : String }


todoDecoder : Decoder Todo
todoDecoder =
    D.succeed Todo
        |> required "id" int
        |> required "title" string
        |> required "detail" string


todosDecoder : Decoder (List Todo)
todosDecoder =
    D.list todoDecoder


type alias GotTodos = Result Http.Error (List Todo)
type alias GotTodo = Result Http.Error Todo

getTodos : String -> Cmd GotTodos
getTodos baseUrl =
    Http.get
        { url = baseUrl ++ "/todos"
        , expect = Http.expectJson (\x -> x) (unwrapResponse todosDecoder)
        }


addTodo : String -> String -> String -> Cmd GotTodo
addTodo baseUrl title detail =
    let
        data =
            E.object
                [ ( "todo_item", E.object [ ( "title", E.string title ), ( "detail", E.string detail ) ] ) ]
    in
    Http.post
        { url = baseUrl ++ "/todos"
        , body = Http.jsonBody data
        , expect = Http.expectJson (\x -> x) (unwrapResponse todoDecoder)
        }
