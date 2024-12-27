module Main exposing (main)

import Browser
import Html exposing (Html, div, input, button, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder)
import Http
import Json.Decode as Decode
import Json.Encode as Encode

type alias Model =
    { name : String
    , message : String
    }

type Msg
    = UpdateName String
    | SendRequest
    | ReceiveResponse (Result Http.Error String)

init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = "", message = "Enter your name and press Submit." }
    , Cmd.none
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateName newName ->
            ( { model | name = newName }, Cmd.none )

        SendRequest ->
            ( model, sendGreetRequest model.name )

        ReceiveResponse (Ok content) ->
            ( { model | message = content }, Cmd.none )

        ReceiveResponse (Err _) ->
            ( { model | message = "Failed to fetch the greeting." }, Cmd.none )

sendGreetRequest : String -> Cmd Msg
sendGreetRequest name =
    let
        body =
            Encode.object
                [ ( "name", Encode.string name ) ]
    in
    Http.post
        { url = "http://127.0.0.1:8080/api/greet"
        , body = Http.jsonBody body
        , expect = Http.expectJson ReceiveResponse messageDecoder
        }

messageDecoder : Decode.Decoder String
messageDecoder =
    Decode.field "message" Decode.string

view : Model -> Html Msg
view model =
    div []
        [ input [ onInput UpdateName, Html.Attributes.placeholder "Enter your name" ] []
        , button [ onClick SendRequest ] [ text "Submit" ]
        , div [] [ text model.message ]
        ]

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
