module HttpErrorHelper exposing (httpErrToString)

import Http exposing (..)


httpErrToString : Http.Error -> String
httpErrToString err =
    case err of
        BadUrl e ->
            "Bad Url: " ++ e

        Timeout ->
            "Timeout"

        NetworkError ->
            "Network Error"

        BadStatus status ->
            "Bad Status: " ++ String.fromInt status

        BadBody body ->
            "Bad Body: " ++ body
