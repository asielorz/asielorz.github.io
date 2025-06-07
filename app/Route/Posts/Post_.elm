module Route.Posts.Post_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Element as UI exposing (px)
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import Posts
import RouteBuilder exposing (App, StatelessRoute)
import SeoConfig exposing (defaultSeo)
import Shared
import View exposing (View)
import Widgets
import MarkdownText
import Style
import Colors


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { post : String
    }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Posts.allBlogPosts
        |> BackendTask.map (List.map Posts.removeDateFromPostFilename)
        |> BackendTask.map (List.map RouteParams)


type alias Data =
    Posts.Post


type alias ActionData =
    {}


data :
    RouteParams
    -> BackendTask FatalError Data
data routeParams =
    Posts.allBlogPosts
        |> BackendTask.map (List.partition (String.contains routeParams.post) >> Tuple.first >> List.head >> Maybe.withDefault routeParams.post)
        |> BackendTask.andThen Posts.loadPost


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    let
        post =
            app.data
    in
    SeoConfig.makeHeadTags
        { defaultSeo
            | title = MarkdownText.removeFormatting post.header.title ++ " — Asier Elorz"
            , description = post |> Posts.description |> MarkdownText.removeFormatting
            , image =
                post.header.image
                    |> Maybe.map (\url -> SeoConfig.imageFromUrl url post.header.image_alt)
                    |> Maybe.withDefault defaultSeo.image
        }


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    let
        post =
            app.data

        image_widget = case post.header.image of
            Nothing -> UI.none
            Just image_url -> Widgets.postBannerImage [] image_url post.header.image_alt

        image_credit_widget = case post.header.image_credit of
            Nothing -> UI.none
            Just image_credit -> Widgets.markdownTitle image_credit
    in
    { title = MarkdownText.removeFormatting post.header.title ++ " — Asier Elorz"
    , body =
        UI.column
            [ UI.spacing 10
            , UI.width UI.fill
            ]
        <|
            [ image_widget
            , UI.el [ UI.centerX, UI_Font.color Colors.dateText, UI_Font.size Style.smallFontSize ] image_credit_widget
            , Widgets.link [] { url = "", label = UI.paragraph [ UI_Font.size Style.titleFontSize, UI_Font.bold ] [ Widgets.markdownTitle post.header.title ] }
            , Widgets.dateText "Publicado el " post.header.date
            , UI.wrappedRow [ UI.spacing 5 ] (List.map Widgets.tag post.header.tags)
            , UI.el [ UI.height (px 20) ] UI.none -- Dummy element to add spacing between the header and the text
            , UI.column [ UI.spacing Style.spacingBeetweenParagraphs, UI.width UI.fill ] <| Widgets.markdownBody post.body
            ]
    }
