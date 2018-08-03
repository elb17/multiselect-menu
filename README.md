# Elm Multiselect Menu

This library helps you create a simple dropdown menu that allows you to select
multiple options at once.


 - Can support options of any type
 - May be configured as a drop-up menu
 - Optional "Check All"/"Uncheck All" buttons

 You can see the dropdown in action here.

## Usage

See the docs and example app ([source](https://github.com/elb17/multiselect-menu/blob/master/examples/Example.elm)) for more details.

A simple example (although more configurations may be added):

```elm
module Example exposing (..)

import MultiselectMenu
import Html
import Html.Attributes as Attr

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }

type alias Model =
    { itemsList : List ( String, Bool )
    , dropdownState : MultiselectMenu.State
    }


init : ( Model, Cmd Msg )
init =
    ( { itemsList = [ ( "Apple", False ), ( "Banana", False ), ( "Clementine", False ), ( "Dragon Fruit", False ) ]
      , dropdownState = MultiselectMenu.init
      }
    , Cmd.none
    )


view : Model -> Html.Html Msg
view { itemsList, dropdownState } =
    Html.div []
        [ Html.div [ Attr.style [ ( "margin", "200px auto" ), ( "width", "200px" ) ] ]
            [ MultiselectMenu.view
                fruitConfig
                dropdownState
                itemsList
            ]
        ]


type Msg
    = SetDropdownState MultiselectMenu.State
    | ToggleDropdownItem (String, Bool)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDropdownState newState ->
            ( { model | dropdownState = newState }
            , Cmd.none
            )
        ToggleDropdownItem item ->
            ( { model | itemsList = MultiselectMenu.toggleItem item model.itemsList }
            , Cmd.none
            )


fruitConfig : MultiselectMenu.Config (String, Bool) Msg
fruitConfig =
    MultiselectMenu.config
        { displayText = "Fruit"
        , stateToMsg = SetDropdownState
        , toggleItem = ToggleDropdownItem
        }
```

