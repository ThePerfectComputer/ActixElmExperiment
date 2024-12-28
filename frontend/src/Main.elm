module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Json.Decode as Decode
import Ports exposing (socket)
import Time exposing (Posix)
import Websockets exposing (EventPort, CommandPort, EventHandlers)


-- MODEL

type alias Model =
    { currentTime : String
    , connected : Bool
    }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { currentTime = "Connecting...", connected = False }
    , socket.open "timeSocket" "ws://127.0.0.1:8080/ws/" []
    )


-- MESSAGES

type Msg
    = SocketOpened
    | SocketClosed
    | SocketMessage String
    | NoOp


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketOpened ->
            ( { model | connected = True }, Cmd.none )

        SocketClosed ->
            ( { model | connected = False }, Cmd.none )

        SocketMessage message ->
            ( { model | currentTime = message }, Cmd.none )
            -- case Decode.decodeString (Decode.field "time" Decode.string) message of
            --     Ok timeString ->
            --         ( { model | currentTime = timeString }, Cmd.none )

            --     Err _ ->
            --         ( { model | currentTime = "Invalid time format" }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    socket.onEvent
        (Websockets.EventHandlers
            (\_ -> Debug.log "SocketOpened" SocketOpened)
            (\_ -> Debug.log "SocketClosed" SocketClosed)
            (\_ -> Debug.log "NoOp" NoOp)
            (\message -> Debug.log "SocketMessage" (SocketMessage message.data))
            (\_ -> Debug.log "NoOp" NoOp)
        )

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ text (if model.connected then "Connected" else "Disconnected")
        , text ("Current Time: " ++ model.currentTime)
        ]


-- MAIN

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
