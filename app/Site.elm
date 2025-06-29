module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import SiteConfig exposing (SiteConfig)
import LanguageTag
import LanguageTag.Language


config : SiteConfig
config =
    { canonicalUrl = "https://asielorz.github.io"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    , Head.rootLanguage <| LanguageTag.build LanguageTag.emptySubtags LanguageTag.Language.es
    ]
        |> BackendTask.succeed
