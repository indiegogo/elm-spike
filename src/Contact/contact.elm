module Contact exposing (fred, wilma)
import Html
import Contact.Json exposing (Contact)
import Element
import Style
import Style.Color as Color
import Style.Font as Font
import Color exposing (black, white, lightGrey)

fred : Contact
fred =
    (Contact
        "Fred Flinstone"
        "fred@flinstone.com"
        "555"
        "Cobblestone Way"
        "Bedrock"
    )


wilma : Contact
wilma =
    (Contact
        "Wilma Flinstone"
        "wilma@flinstone.com"
        "555"
        "Cobblestone Way"
        "Bedrock"
    )




        
