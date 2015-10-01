{--

Trying to remake this: http://jenniferdewalt.com/glob_glob/globs/1

--}

module GlobGlob where

import Signal exposing (Address, Mailbox, mailbox)
import Keyboard
import Html exposing (Html, div)
import Html.Attributes exposing (attribute)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Time exposing (every, second)
import String
import Window
import Http
import Task exposing (andThen, Task)


timeToPlay : Float
timeToPlay = 10


type alias Radius = Int


type GameStage =
          Initial
        | Playing
        | Done


type alias Model = {
          bestScore : Radius
        , cur : Radius
        , left : Float
        , stage : GameStage
        -- Effect inducing variables, should be refactored to use Effects module, which
        -- clearly separates the model from the state used to trigger side effects such as GET HTTP requests.
        , getBestScore : Bool
}


type Action =
           GameTime Float
         | Space Bool
         | Reset
         | NoOp
         -- These three are a kludge since we want to do a "trigger once" GET, and we are using a model state variable for that.
         | BestScoreUpdated Radius
         | BestScoreFetch
         | BestScoreStopFetching


actions : Signal.Mailbox Action
actions =
        Signal.mailbox NoOp


update : Action -> Model -> Model
update action model =
        let
            done = model.left <= 0
        in
            case action of
                    -- assume every second
                    GameTime _ ->
                            case model.stage of
                                    Playing ->
                                            let
                                                left = Basics.max 0 (model.left - 1)
                                                stage = if left <= 0 then Done else Playing
                                            in
                                                { model | left <- left, stage <- stage }
                                    _ ->
                                            model
                    Space True ->
                            case model.stage of
                                    Initial ->
                                            { model | stage <- Playing }
                                    Playing ->
                                            { model | cur <- model.cur + 1 }
                                    Done ->
                                            { model | getBestScore <- True }
                    BestScoreUpdated newScore ->
                      { model | bestScore <- newScore }
                    Reset ->
                      { init | bestScore <- model.bestScore }
                    BestScoreStopFetching ->
                      { model | getBestScore <- False }
                    _ ->
                      model


init : Model
init =
        { bestScore = 0
        , left = timeToPlay
        , cur = 0
        , stage = Initial
        , getBestScore = True}


input : Signal Action
input =
        Signal.mergeMany [
                  (Signal.map Space Keyboard.space)
                , (Signal.map GameTime (every second))
                , actions.signal
                , (Signal.map BestScoreUpdated serverBestScore.signal)
                ]

model : Signal Model
model =
        Signal.foldp update init input


endscreen : Model -> Svg
endscreen model =
        g []
        [
                  text' [x "50", y "25", textAnchor "middle", fontSize "5"] [text (String.join "" ["You grew your glob to ", toString model.cur, " awesome units!"])]
                , text' [x "50", y "50", textAnchor "middle", fontSize "5"] [text (if model.cur > model.bestScore then
                   "New record!"
                   else
                   "Too bad you couldn't beat the last glob grower, though")]
                , text' [onClick <| Signal.message actions.address Reset, Svg.Attributes.cursor "pointer", x "50", y "75", textAnchor "middle", fontSize "5"] [text "Play Again?"]
        ]

circleFill : (Float, Float, Float, Float) -> Svg.Attribute
circleFill (r, g, b, a) =
        let
            color = (List.map (toString << round << (*) 255) [r, g, b]) ++ [toString a]
        in
            Svg.Attributes.fill <| "rgba(" ++ (String.join "," color) ++ ")"


originalHref : String
originalHref = "http://jenniferdewalt.com/glob_glob/globs/1"


view : (Int, Int) -> Model -> Html
view (swidth, sheight) model =
        let
            done = model.stage == Done
            alpha = if done then 0.3 else 1.0
            lastColor = (1.0, 0.0, 0.0, alpha)
            curColor = (0.0, 0.0, 1.0, alpha)
            rhelper r = toString ((toFloat r) * 0.1)
            secondsString = String.join " " ["Remaining seconds", toString model.left]
            secondsText = text' [ textAnchor "middle", x "50", y "30", fontSize "8" ] [ text secondsString ]
            widthString = (toString swidth) ++ "px"
            heightString = (toString (sheight - 20)) ++ "px"
            initial = text' [ textAnchor "middle", x "50", y "30", fontSize "8" ] [text "Press Space to start" ]
        in
            svg [ version "1.1", width widthString, height heightString, viewBox "0 0 100 100" ]
            [
                      Svg.a [ Svg.Attributes.cursor "pointer"
                            , attribute "title" originalHref
                            , onClick (Signal.message setLocationMailbox.address originalHref)
                            ]
                            [ text' [ x "50"
                                    , y "10"
                                    , textAnchor "middle"
                                    , fontSize "2"]
                                    [ text <| "Remake in Elm of Jeniffer Dewalte's Glob Glob"]
                            ]
                    , circle [cx "20", cy "50", circleFill curColor, r (rhelper model.cur) ] []
                    , circle [cx "80", cy "50", circleFill lastColor, r (rhelper model.bestScore) ] []
                    , case model.stage of
                            Initial -> initial
                            Playing -> secondsText
                            Done -> endscreen model
            ]


setLocationMailbox : Signal.Mailbox String
setLocationMailbox =
        Signal.mailbox ""

port setLocation : Signal String
port setLocation =
        setLocationMailbox.signal


serverBestScore : Mailbox Radius
serverBestScore =
  mailbox 0


port serverBestScoreGet : Signal (Task Http.Error ())
port serverBestScoreGet =
  let
    sendJusts radiusM =
      case radiusM of
        Just r ->
          Signal.send serverBestScore.address r
        Nothing ->
          Task.succeed ()
    getTask shouldI =
      case shouldI of
        True ->
          Signal.send actions.address BestScoreStopFetching `andThen` (\_ -> Http.getString "/best") `andThen` (decodeBestResult >> Task.succeed)  `andThen` sendJusts
        False ->
          Task.succeed ()
  in
    Signal.map (.getBestScore >> getTask) model


-- TODO: use Json.Decode (no internet access)
decodeBestResult : String -> Maybe Radius
decodeBestResult s =
  case String.split ":" s of
    [a, b] ->
      case String.split "}" b of
        [a, _] ->
          case String.toInt (String.trim a) of
            Ok best ->
              Just best
            _ ->
              Nothing
        _ ->
          Nothing
    _ ->
      Nothing


modelCur : Signal Radius
modelCur =
  Signal.map (\model -> model.cur) model


port setBestScore : Signal (Task Http.RawError Http.Response)
port setBestScore =
  Signal.map postBestScore (Signal.dropRepeats (Signal.map2 Basics.max serverBestScore.signal modelCur))


postBestScore : Radius -> Task Http.RawError Http.Response
postBestScore r =
  Http.send Http.defaultSettings
    { verb = "POST"
    , headers = [("Content-Type", "application/x-www-form-urlencoded")]
    , url = "/best"
    , body = Http.string ("score=" ++ (toString r))}
  `andThen` Task.succeed


main : Signal Html
main =
        Signal.map2 view Window.dimensions model
