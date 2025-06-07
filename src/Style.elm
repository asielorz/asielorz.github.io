module Style exposing (..)

import Element.Font as UI_Font exposing (Font)

regularFontSize : Int
regularFontSize = 20

smallFontSize : Int
smallFontSize = 16

titleFontSize : Int
titleFontSize = 25

inlineMonospaceFontSize : Int
inlineMonospaceFontSize = 17

blockMonospaceFontSize : Int
blockMonospaceFontSize = 16

regularFont : List Font
regularFont = [ UI_Font.typeface "Times New Roman", UI_Font.serif ]

spacingBeetweenParagraphs : Int
spacingBeetweenParagraphs = 15
