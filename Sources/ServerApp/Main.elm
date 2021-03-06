module Main exposing (..)

import Color exposing (rgb)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (decodeString)
import Json.Encode as Encode
import Navigation
import Style
import Style.Color
import Style.Font
import WebSocket


type Model
    = Waiting String (Maybe Game)
    | Ready String Game
    | Error


type Msg
    = NoOp
    | Incoming (Result String Game)
    | Move Int


type alias Game =
    ( Status, List Space )


type Status
    = Finished
    | Ongoing


type Space
    = Empty Int
    | Marked String


main : Program Never Model Msg
main =
    Navigation.program
        (\_ -> NoOp)
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- LOOP


init : Navigation.Location -> ( Model, Cmd Msg )
init { protocol, host } =
    let
        url =
            if protocol == "https:" then
                "wss://tictactoe-swift.herokuapp.com/game"
            else
                "ws://" ++ host ++ "/game"
    in
    ( Waiting url Nothing, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( _, Error ) ->
            ( model, Cmd.none )

        ( Incoming (Err reason), _ ) ->
            ( Debug.log reason Error, Cmd.none )

        ( Incoming (Ok game), Waiting url _ ) ->
            ( Ready url game, Cmd.none )

        ( Incoming (Ok game), Ready url _ ) ->
            ( Ready url game, Cmd.none )

        ( Move i, Ready url board ) ->
            ( Waiting url (Just board), WebSocket.send url (encode i) )

        ( Move i, _ ) ->
            ( model, Cmd.none )


encode : Int -> String
encode move =
    [ ( "move", Encode.int move ) ]
        |> Encode.object
        |> Encode.encode 0



-- HTML


type Class
    = Body
    | Note
    | Board
    | Space
    | Mark


type Variation
    = Clickable


type Click
    = Enabled
    | Disabled


font : { name : String, url : String }
font =
    { name = "Permanent Marker"
    , url = "https://fonts.googleapis.com/css?family=Permanent+Marker"
    }


stylesheet : Style.StyleSheet Class Variation
stylesheet =
    Style.stylesheet
        [ Style.style Body
            [ Style.Font.typeface [ font.name, "sans-serif" ]
            , Style.Font.bold
            , Style.Color.text (rgb 41 60 75)
            ]
        , Style.style Note
            [ Style.Font.size 20
            ]
        , Style.style Board
            [ Style.Color.background (rgb 41 60 75)
            ]
        , Style.style Space
            [ Style.variation Clickable
                [ Style.cursor "pointer"
                , Style.hover
                    [ Style.Color.background (rgb 240 128 128) ]
                ]
            , Style.Font.center
            , Style.Color.background (rgb 255 255 255)
            ]
        , Style.style Mark
            [ Style.Font.size 80
            ]
        ]


view : Model -> Html Msg
view model =
    Html.body []
        [ Html.node "style"
            [ Html.Attributes.type_ "text/css" ]
            [ Html.text ("@import url(" ++ font.url ++ ")") ]
        , viewHelp model
            |> column Body [ center, verticalCenter ]
            |> viewport stylesheet
        ]


viewHelp : Model -> List (Element Class Variation Msg)
viewHelp model =
    case model of
        Waiting _ maybeGame ->
            [ viewNote (text "Please hold...")
            , whenJust maybeGame (Tuple.second >> viewBoard Disabled)
            ]

        Ready _ ( Ongoing, board ) ->
            [ viewNote (text "Your turn!")
            , viewBoard Enabled board
            ]

        Ready _ ( Finished, board ) ->
            [ viewNote <|
                row Note
                    []
                    [ text "Game over—"
                    , link "/" (underline "Play again?")
                    ]
            , viewBoard Disabled board
            ]

        Error ->
            [ viewNote (text "Something went wrong :(")
            ]


viewNote : Element Class Variation Msg -> Element Class Variation Msg
viewNote content =
    el Note [ moveUp 36 ] (header content)


viewBoard : Click -> List Space -> Element Class Variation Msg
viewBoard click board =
    table Board
        [ center, verticalCenter, spacing 6 ]
        (List.map (List.map (viewSpace click)) (square board))


viewSpace : Click -> Space -> Element Class Variation Msg
viewSpace click space =
    let
        base =
            [ center
            , verticalCenter
            , width (px 100)
            , height (px 100)
            ]
    in
    case ( click, space ) of
        ( Enabled, Empty i ) ->
            let
                event =
                    Element.Events.onClick (Move i)
            in
            el Space (event :: vary Clickable True :: base) empty

        ( Disabled, Empty _ ) ->
            el Space base empty

        ( _, Marked x ) ->
            el Space base <|
                el Mark [ center, verticalCenter ] (text x)


square : List a -> List (List a)
square list =
    let
        axis =
            List.length >> toFloat >> sqrt >> round
    in
    squareHelp (axis list) list []


squareHelp : Int -> List a -> List (List a) -> List (List a)
squareHelp n list acc =
    if List.isEmpty list then
        List.reverse acc
    else
        squareHelp n (List.drop n list) (List.take n list :: acc)



-- FETCH


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Waiting url _ ->
            WebSocket.listen url (Incoming << decodeString decoder)

        Ready url ( Ongoing, _ ) ->
            WebSocket.keepAlive url

        Ready url ( Finished, _ ) ->
            Sub.none

        Error ->
            Sub.none


decoder : Decode.Decoder Game
decoder =
    let
        toSpace i x =
            if String.isEmpty x then
                Empty i
            else
                Marked x

        toStatus over =
            if over then
                Finished
            else
                Ongoing
    in
    Decode.map2 (,)
        (Decode.map toStatus (Decode.field "over" Decode.bool))
        (Decode.map (List.indexedMap toSpace) (Decode.field "board" (Decode.list Decode.string)))
