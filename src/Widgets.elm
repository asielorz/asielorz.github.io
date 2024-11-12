module Widgets exposing 
    (link
    , blueLink
    , tag
    , heading
    , complexHeading
    , dateText
    , searchBox
    , postMenuEntry
    , horizontalSeparator
    , embedYoutubeVideo
    , referenceSuperscript
    , referenceFootnote
    , postBannerImage
    , markdownBody
    , markdownTitle
    )

import Colors
import DateTime
import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Element.Input as UI_Input
import Element.Region as UI_Region
import Fontawesome
import Html
import Html.Attributes
import Posts
import SyntaxHighlight
import Url
import MarkdownText exposing (MarkdownText)
import Markdown.Renderer.ElmUi as MarkdownRenderer exposing (Error(..))
import Markdown.Parser
import Markdown.Renderer
import Markdown.Block
import Markdown.Html
import Parser
import Parser.Advanced
import Style


link : List (UI.Attribute msg) -> { url : String, label : UI.Element msg } -> UI.Element msg
link attributes args =
    UI.link (UI.mouseOver [ UI_Font.color Colors.linkBlue ] :: attributes) args


blueLink : List (UI.Attribute msg) -> { url : String, label : UI.Element msg } -> UI.Element msg
blueLink attributes args =
    UI.link (UI_Font.color Colors.linkBlue :: attributes) args


tag : String -> UI.Element msg
tag tag_name =
    UI.link []
        { url = "/tags#" ++ Url.percentEncode tag_name
        , label =
            UI.row
                [ UI.paddingXY 7 3
                , UI_Background.color Colors.tagBackground
                , UI_Font.color Colors.tagText
                , UI_Font.size 16
                , UI_Border.rounded 5
                , UI_Border.width 1
                , UI_Border.color Colors.tagText
                , UI.spacing 3
                , UI.mouseOver [ UI_Background.color Colors.tagHoveredBackground, UI_Font.color Colors.tagHoveredText ]
                ]
                [ Fontawesome.text [] "\u{F02B}" -- fa-tag
                , UI.text tag_name
                ]
        }


heading : List (UI.Attribute msg) -> Int -> String -> UI.Element msg
heading attributes level label =
    complexHeading attributes level label [ UI.text label ]


complexHeading : List (UI.Attribute msg) -> Int -> String -> List (UI.Element msg) -> UI.Element msg
complexHeading attributes level label children =
    let
        id =
            label
                |> String.trim
                |> String.toLower
                |> String.replace " " "-"
                |> Url.percentEncode

        font_size =
            case level of
                1 ->
                    32

                2 ->
                    28

                3 ->
                    26

                4 ->
                    24

                5 ->
                    22

                _ ->
                    20
    in
    UI.el
        [ UI.width UI.fill
        ]
    <|
        UI.el
            ([ UI_Font.size font_size
             , UI_Region.heading level
             , UI.htmlAttribute <| Html.Attributes.id id
             , UI.width UI.fill
             , UI.inFront <|
                link
                    [ UI.paddingXY 10 0
                    , UI.centerY
                    , UI.alpha 0
                    , UI.mouseOver [ UI.alpha 1 ]
                    , UI.width UI.fill
                    , UI.moveLeft 50
                    ]
                    { url = "#" ++ id, label = Fontawesome.text [] "\u{F0C1}" }
             ]
                ++ attributes
            )
        <|
            UI.paragraph [ UI.width UI.fill, UI_Font.bold ] children


dateText : String -> DateTime.Date -> UI.Element msg
dateText prefix date =
    UI.paragraph [ UI_Font.italic, UI_Font.color Colors.dateText ] [ UI.text <| prefix ++ DateTime.toStringText date ]


searchBox : (String -> msg) -> String -> UI.Element msg
searchBox make_message current_text =
    UI_Input.text
        [ UI.width UI.fill
        , UI_Background.color Colors.widgetBackground
        , UI_Border.color Colors.widgetBorder
        ]
        { onChange = make_message
        , text = current_text
        , placeholder = Just <| UI_Input.placeholder [] (UI.text "Buscar...")
        , label =
            UI_Input.labelLeft
                [ UI.centerY
                , UI_Font.size 30
                , UI.paddingEach { right = 10, top = 0, bottom = 0, left = 0 }
                ]
                (Fontawesome.text [] "\u{F002}" {- fa-magnifying-glass -})
        }


postMenuEntry : Posts.PostHeader -> UI.Element msg
postMenuEntry post =
    UI.row
        [ UI.spacing 10
        , UI.width UI.fill
        ]
        [ UI.el [ UI.alignTop ] <| UI.text "•"
        , UI.column [ UI.width UI.fill, UI.spacing 5 ]
            [ UI.paragraph [] [ link [] { url = post.url, label = markdownTitle post.title } ]
            , UI.wrappedRow [ UI.spacing 5 ]
                (dateText "" post.date :: List.map tag post.tags)
            ]
        ]


horizontalSeparator : Int -> UI.Element msg
horizontalSeparator width =
    UI.el
        [ UI.height (px width)
        , UI_Background.color Colors.horizontalSeparator
        , UI.width UI.fill
        ]
        UI.none


embedYoutubeVideo : List (UI.Attribute msg) -> String -> UI.Element msg
embedYoutubeVideo attributes youtube_video_id =
    let
        default_attributes =
            [ UI.width <| UI.maximum 560 UI.fill
            ]
    in
    UI.el (default_attributes ++ attributes) <|
        UI.html <|
            Html.iframe
                [ Html.Attributes.src <| "https://www.youtube.com/embed/" ++ youtube_video_id
                , Html.Attributes.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                , Html.Attributes.attribute "allowfullscreen" "true"
                , Html.Attributes.style "aspect-ratio" "16 / 9"
                ]
                []


referenceSuperscript : String -> UI.Element msg
referenceSuperscript id =
    blueLink []
        { url = "#footnote-" ++ id
        , label = UI.html <| Html.sup [ Html.Attributes.id <| "ref-" ++ id ] [ Html.text <| "[" ++ id ++ "]" ]
        }


referenceFootnote : String -> UI.Element msg
referenceFootnote id =
    blueLink [ UI.htmlAttribute <| Html.Attributes.id <| "footnote-" ++ id, UI.paddingEach { top = 0, bottom = 0, left = 0, right = 10 } ]
        { url = "#ref-" ++ id
        , label = UI.text <| "[" ++ id ++ "]"
        }


postBannerImage : List (UI.Attribute msg) -> String -> Maybe String -> UI.Element msg
postBannerImage attributes image_url alt_text =
    UI.image
        ([ UI.width UI.fill
         , UI.htmlAttribute <| Html.Attributes.style "aspect-ratio" "750 / 250"
         , UI.htmlAttribute <| Html.Attributes.style "flex-basis" "auto"
         , UI_Border.rounded 10
         , UI.clip
         ]
            ++ attributes
        )
        { src = image_url
        , description = alt_text |> Maybe.withDefault ""
        }


markdownBody : MarkdownText -> List (UI.Element msg)
markdownBody body =
    let
        parsed_markdown =
            parseMarkdown <| MarkdownText.source body
    in
    case parsed_markdown of
        Ok value ->
            value

        Err error ->
            [ UI.text <| "Error at parsing markdown: " ++ markdownErrorToString error ]


markdownTitle : MarkdownText -> (UI.Element msg)
markdownTitle body = 
    markdownBody body |> List.head |> Maybe.withDefault (UI.text "Error at parsing markdown: Body does not contain a single element")

----------------------------------------------------------------------------------------------------------------------
-- Markdown impl

parseMarkdown : String -> Result Error (List (UI.Element msg))
parseMarkdown markdown_source =
    Markdown.Parser.parse markdown_source
        |> Result.mapError ParseError
        |> Result.andThen
            (\blocks ->
                Markdown.Renderer.render markdownRenderer blocks
                    |> Result.mapError RenderError
            )


markdownRenderer : Markdown.Renderer.Renderer (UI.Element msg)
markdownRenderer =
    let
        defaultRenderer =
            MarkdownRenderer.renderer
    in
    { defaultRenderer
        | html =
            Markdown.Html.oneOf
                [ Markdown.Html.tag "youtube"
                    (\id _ ->
                        embedYoutubeVideo [ UI.centerX ] id
                    )
                    |> Markdown.Html.withAttribute "id"
                , Markdown.Html.tag "ref"
                    (\id _ ->
                        referenceSuperscript id
                    )
                    |> Markdown.Html.withAttribute "id"
                , Markdown.Html.tag "footnote"
                    (\id _ ->
                        referenceFootnote id
                    )
                    |> Markdown.Html.withAttribute "id"
                ]
        , paragraph = UI.paragraph [ UI_Font.justify, UI.width UI.fill ]
        , unorderedList = unorderedList
        , link = \{ destination } body -> blueLink [] { url = destination, label = UI.paragraph [] body }
        , heading = \{ level, rawText, children } -> complexHeading [ UI.paddingEach { top = 10, left = 0, bottom = 0, right = 0 } ] (Markdown.Block.headingLevelToInt level) rawText children
        , codeBlock = codeBlock
        , codeSpan = codeSpan
        , blockQuote = blockQuote
    }


unorderedListItem : Markdown.Block.ListItem (UI.Element msg) -> UI.Element msg
unorderedListItem (Markdown.Block.ListItem _ children) =
    let
        bullet =
            UI.el
                [ UI.paddingEach { top = 4, bottom = 0, left = 2, right = 8 }
                , UI.alignTop
                ]
            <|
                UI.text "•"
    in
    UI.row []
        [ bullet
        , UI.paragraph [ UI.width UI.fill ] children
        ]


unorderedList : List (Markdown.Block.ListItem (UI.Element msg)) -> UI.Element msg
unorderedList items =
    List.map unorderedListItem items
        |> UI.column [ UI.spacing 5 ]


codeSpan : String -> UI.Element msg
codeSpan raw_text = UI.el 
    [ UI_Font.family [ UI_Font.monospace ]
    , UI_Font.size Style.inlineMonospaceFontSize
    , UI_Background.color Colors.widgetBackground
    ] 
    <| UI.text raw_text


codeBlock : { body : String, language : Maybe String } -> UI.Element msg
codeBlock { body, language } = 
    let
        maybe_syntax = Maybe.andThen SyntaxHighlight.syntax_for language
        color_to_string {r, g, b} = "rgb(" ++ String.fromInt r ++ ", " ++ String.fromInt g ++ ", " ++ String.fromInt b ++ ")"
        render block = Html.span [ Html.Attributes.style "color" (color_to_string block.color) ] [ Html.text block.text ]
        block_content = maybe_syntax
            |> Maybe.map (\syntax -> SyntaxHighlight.highlight syntax body)
            |> Maybe.map (List.map render)
            |> Maybe.withDefault [ Html.text body ]
        code_block = Html.pre [] block_content |> UI.html
        title language_name = UI.el 
            [ UI_Font.size Style.regularFontSize
            , UI.paddingXY 0 5
            ] 
            <| UI.text language_name
        content = case maybe_syntax of
            Nothing -> [ code_block ]
            Just syntax ->
                [ title syntax.name
                , horizontalSeparator 1
                , code_block
                ]
    in
        UI.column
            [ UI_Border.width 1
            , UI_Border.color Colors.footerBorder
            , UI_Background.color Colors.widgetBackground
            , UI_Border.rounded 10
            , UI.paddingXY 15 0
            , UI.width UI.fill
            , UI_Font.size Style.blockMonospaceFontSize
            , UI.scrollbarX
            -- This is a hack to make UI.scrollbarX work. Otherwise the browser will make the div have a height of 1 px for some reason.
            , UI.htmlAttribute <| Html.Attributes.style "flex-basis" "auto"
            ]
            content

blockQuote : List (UI.Element msg) -> UI.Element msg
blockQuote paragraphs =
    UI.el [ UI.paddingXY 0 4 ] <|
        UI.column
            [ UI.padding 10
            , UI.spacing 20
            , UI_Border.widthEach { top = 0, bottom = 0, right = 0, left = 10 }
            , UI_Border.color Colors.blockQuoteLeftBar
            ]
            paragraphs


type alias MarkdownParserError =
    Parser.Advanced.DeadEnd String Parser.Problem


markdownErrorToString : MarkdownRenderer.Error -> String
markdownErrorToString error =
    case error of
        ParseError parser_error ->
            "Parse error: " ++ markdownParserErrorsToString parser_error

        RenderError error_message ->
            "Render error: " ++ error_message


markdownParserErrorsToString : List MarkdownParserError -> String
markdownParserErrorsToString errors =
    errors
        |> List.map markdownParserErrorToString
        |> String.join "\n\n"


markdownParserErrorToString : MarkdownParserError -> String
markdownParserErrorToString error =
    let
        context_stack_as_string =
            error.contextStack
                |> List.map contextStackFrameToString
                |> List.map (\s -> "\n - " ++ s)
                |> String.join ""
    in
    "(row: " ++ String.fromInt error.row ++ " col: " ++ String.fromInt error.col ++ ") " ++ parserProblemToString error.problem ++ context_stack_as_string


contextStackFrameToString : { row : Int, col : Int, context : String } -> String
contextStackFrameToString frame =
    "(row: " ++ String.fromInt frame.row ++ " col: " ++ String.fromInt frame.col ++ ") " ++ frame.context


parserProblemToString : Parser.Problem -> String
parserProblemToString problem =
    case problem of
        Parser.Expecting str ->
            "Expecting " ++ str

        Parser.ExpectingInt ->
            "Expecting int"

        Parser.ExpectingHex ->
            "Expecting hex"

        Parser.ExpectingOctal ->
            "Expecting octal"

        Parser.ExpectingBinary ->
            "Expecting binary"

        Parser.ExpectingFloat ->
            "Expecting float"

        Parser.ExpectingNumber ->
            "Expecting number"

        Parser.ExpectingVariable ->
            "Expecting variable"

        Parser.ExpectingSymbol str ->
            "Expecting symbol " ++ str

        Parser.ExpectingKeyword str ->
            "Expecting keyword " ++ str

        Parser.ExpectingEnd ->
            "Expecting end"

        Parser.UnexpectedChar ->
            "Unexpected char"

        Parser.Problem str ->
            "Problem: " ++ str

        Parser.BadRepeat ->
            "Bad repeat"