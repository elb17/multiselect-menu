module MultiselectMenu
    exposing
        ( Colors
        , Config
        , Direction(Down, Up)
        , GroupOperations(None, SelectAll)
        , State
        , config
        , customConfig
        , defaultColors
        , init
        , selectAll
        , toggleItem
        , view
        )

{-| This package helps you create a simple dropdown with a checklist that allows
you to select multiple options at once.


# View

@docs view


# State

@docs State, init


# Configuration

@docs Config, config, customConfig, GroupOperations, Direction, Colors, defaultColors


# Helper Functions

@docs toggleItem, selectAll

-}

import Html exposing (Html, button, div, input, span, text)
import Html.Attributes exposing (checked, style, type_)
import Html.Events exposing (onClick)
import List


-- STATE


{-| Tracks whether the dropdown checklist is displayed.
-}
type State
    = State { displayDropdown : Bool }


{-| Create a dropdown `State`.
-}
init : State
init =
    State
        { displayDropdown = False
        }



-- CONFIG


{-| Configuration for your dropdown.

Note: Your configuration should only appear in your `view` code, not your `Model`.

-}
type Config itemType msg
    = Config
        { displayText : String
        , stateToMsg : State -> msg
        , toggleItem : itemType -> msg
        , groupOperations : GroupOperations msg
        , displayDirection : Direction
        , colorStyles : ColorStyle
        , itemToString : itemType -> String
        , itemToBool : itemType -> Bool
        }


{-| Create the `Config` for your `view` code.

For example:

    import MultiselectMenu

    type Msg = ToggleDropdownItem (String, Bool)
             | SetDropdownState MultiselectMenu.State
             | ...

    config : MultiselectMenu.Config (String, Bool) Msg
    config =
        MultiselectMenu.config
            { toggleItem = ToggleDropdownItem
            , stateToMsg = SetDropdownState
            , displayText = "Example Dropdown"
            }

You provide the following information for your dropdown configuration:

  - `toggleItem` &mdash; a message to toggle whether an item is checked
  - `stateToMsg` &mdash; a way to send new dropdown states to your app as messages
  - `displayText` &mdash; text that will be displayed on the dropdown button

Using `config` requires that you store your list of dropdown options in the format: `List (String, Bool)`.
In this case, the first value of each pair is what is displayed in the menu, and the second is whether
or not the option is checked.

For example: `itemsList = [("Option 1", False), ("Option 2", True), ("Option 3", True)]`

-}
config :
    { displayText : String
    , stateToMsg : State -> msg
    , toggleItem : ( String, Bool ) -> msg
    }
    -> Config ( String, Bool ) msg
config { displayText, stateToMsg, toggleItem } =
    Config
        { displayText = displayText
        , stateToMsg = stateToMsg
        , toggleItem = toggleItem
        , groupOperations = None
        , displayDirection = Down
        , colorStyles = colorStyleCons defaultColors
        , itemToString = \item -> Tuple.first item
        , itemToBool = \item -> Tuple.second item
        }


{-| This is just like `config`, but you can specify more fields for the dropdown and use items of any type.

In addition to the information needed for `config`, you also provide:

  - `groupOperations` a message to check or uncheck all dropdown items. If you do not want to use the Check All/Uncheck All buttons, set this to `None`.
  - `displayDirection` &mdash; the direction that the checklist will be displayed (`Up` or `Down`)
  - `colors` &mdash; the colors and borders for your dropdown
  - `itemToString` &mdash; a function to convert an item in your list to a string for display purposes.
    If you are storing your items in a list like this: `[ ("Option 1", True), ("Option 2", False) ]`,
    then `itemToString = (\item -> Tuple.first item)`
  - `itemToBool` &mdash; a function to convert an item in your list to the `Bool` representing whether it is checked.
    If your items look like this: `("Option 1", False)`, then `itemToBool = (\item -> Tuple.second item)`

In the type declaration of `customConfig`, the items in your `itemsList` may be of any type, not just `(String, Bool)`.
For example, if the items in your list are `(Int, Bool)`, your `customConfig` type would be: `Config (Int, Bool) Msg`.

-}
customConfig :
    { displayText : String
    , stateToMsg : State -> msg
    , toggleItem : itemType -> msg
    , groupOperations : GroupOperations msg
    , displayDirection : Direction
    , colors : Colors
    , itemToString : itemType -> String
    , itemToBool : itemType -> Bool
    }
    -> Config itemType msg
customConfig { displayText, stateToMsg, toggleItem, groupOperations, displayDirection, colors, itemToString, itemToBool } =
    Config
        { toggleItem = toggleItem
        , displayText = displayText
        , stateToMsg = stateToMsg
        , groupOperations = groupOperations
        , displayDirection = displayDirection
        , colorStyles = colorStyleCons colors
        , itemToString = itemToString
        , itemToBool = itemToBool
        }


{-| If you want to display the Check All/Uncheck All buttons, the `(Bool -> msg)` is a message to check or uncheck all dropdown items.

If you don't want to use the Check All/Uncheck All buttons, set this to `None`.

-}
type GroupOperations msg
    = None
    | SelectAll (Bool -> msg)


{-| The direction that the checklist will be displayed.
-}
type Direction
    = Up
    | Down


{-| Custom colors may be set for the dropdown.
-}
type alias Colors =
    { backgroundColor : String
    , backgroundBorder : String
    , buttonColor : String
    , buttonBorder : String
    , textColor : String
    }


{-| The colors used in config by default.
-}
defaultColors : Colors
defaultColors =
    { backgroundColor = "white"
    , backgroundBorder = "#e0e0e0"
    , buttonColor = "#eeeeee"
    , buttonBorder = "#d0d0d0"
    , textColor = "black"
    }


type alias ColorStyle =
    { backgroundColor : List ( String, String )
    , buttonColor : List ( String, String )
    , textColor : List ( String, String )
    }


colorStyleCons : Colors -> ColorStyle
colorStyleCons colors =
    { backgroundColor =
        [ ( "background-color", colors.backgroundColor )
        , ( "border", "1px solid " ++ colors.backgroundBorder )
        ]
    , buttonColor =
        [ ( "background-color", colors.buttonColor )
        , ( "border", "1px solid " ++ colors.buttonBorder )
        ]
    , textColor = [ ( "color", colors.textColor ) ]
    }



-- VIEW


{-| Take a list of options and turn it into a multi-select dropdown. The `Config` argument
is the configuration for the dropdown. The `State` argument describes whether the dropdown
menu is displayed or not. `itemType` is the type of each dropdown option in your list. So
if you store your options in a `List (String, Bool)` format, `itemType` would be `(String, Bool)`.

Note: The `State` should be in your `Model`. The `Config` and list of options for the dropdown
should live in your `view` code.

-}
view : Config itemType msg -> State -> List itemType -> Html msg
view (Config config) (State state) itemsList =
    div
        [ style [ ( "position", "relative" ) ] ]
        [ button
            [ style (css.toggleButton ++ config.colorStyles.buttonColor)
            , onClick (toggleDisplay (State state) |> config.stateToMsg)
            ]
            [ span [ style config.colorStyles.textColor ] [ text config.displayText ] ]
        , if state.displayDropdown then
            div []
                [ viewButtonsWrapper
                    (Config config)
                    itemsList
                , viewChecklist
                    (Config config)
                    itemsList
                ]
          else
            text ""
        ]


viewChecklist : Config itemType msg -> List itemType -> Html msg
viewChecklist (Config config) itemsList =
    let
        cssStyle =
            css.checklist
                ++ config.colorStyles.backgroundColor
                ++ (if config.displayDirection == Down then
                        css.checklistBelow
                    else
                        css.checklistAbove
                   )
    in
    div
        [ style cssStyle ]
        (List.map (viewRow (Config config)) itemsList)


viewRow : Config itemType msg -> itemType -> Html msg
viewRow (Config config) item =
    div
        [ style
            [ ( "margin", "10px 10px 0px" ) ]
        ]
        [ span []
            [ input
                [ type_ "checkbox"
                , style
                    ([ ( "margin-right", "5px" ) ]
                        ++ config.colorStyles.backgroundColor
                    )
                , checked (config.itemToBool item)
                , onClick (config.toggleItem item)
                ]
                []
            ]
        , span [ style config.colorStyles.textColor ] [ text (config.itemToString item) ]
        ]


viewButtonsWrapper : Config itemType msg -> List itemType -> Html msg
viewButtonsWrapper (Config config) itemsList =
    let
        cssStyle =
            css.checkAllButtons
                ++ config.colorStyles.backgroundColor
                ++ (if config.displayDirection == Up then
                        css.checkAllButtonsBelow
                    else
                        css.checkAllButtonsAbove
                   )
    in
    case config.groupOperations of
        SelectAll groupOperations ->
            div [ style [ ( "position", "absolute" ), ( "width", "100%" ) ] ]
                [ viewCheckAllButton config.colorStyles.textColor cssStyle groupOperations
                , viewUncheckAllButton config.colorStyles.textColor cssStyle groupOperations
                ]

        None ->
            text ""


viewCheckAllButton : List ( String, String ) -> List ( String, String ) -> (Bool -> msg) -> Html msg
viewCheckAllButton textColor cssStyle groupOperations =
    button
        [ style cssStyle
        , onClick (groupOperations True)
        ]
        [ span [ style textColor ] [ text "Check All" ] ]


viewUncheckAllButton : List ( String, String ) -> List ( String, String ) -> (Bool -> msg) -> Html msg
viewUncheckAllButton textColor cssStyle groupOperations =
    button
        [ style (cssStyle ++ [ ( "border-left", "none" ) ])
        , onClick (groupOperations False)
        ]
        [ span [ style textColor ] [ text "Uncheck All" ] ]



-- HELPERS


toggleDisplay : State -> State
toggleDisplay (State state) =
    State { state | displayDropdown = not state.displayDropdown }


{-| A function to toggle whether an item is checked. This may be useful to call in your update.

`toggleItem` requires the inputted item list to have type: `List (anyType, Bool)` where the `Bool`
represents whether the item is checked.

If your model stores data in a different format, you can write your own version of `toggleItem` in your `update`.

-}
toggleItem : ( nameType, Bool ) -> List ( nameType, Bool ) -> List ( nameType, Bool )
toggleItem ( itemName, itemChecked ) itemsList =
    List.map
        (\(( name, isChecked ) as item) ->
            if name == itemName then
                ( name, not isChecked )
            else
                item
        )
        itemsList


{-| A function to check or uncheck all items in your item list. This may be useful to call in your update.

`selectAll` requires the inputted item list to have type: `List (anyType, Bool)` where the `Bool` represents
whether the item is checked.

If you model stores data in a different format, you can write your own version of `selectAll` in your `update`.

-}
selectAll : Bool -> List ( nameType, Bool ) -> List ( nameType, Bool )
selectAll check itemsList =
    List.map (\( item, _ ) -> ( item, check )) itemsList



-- CSS


css :
    { checklist : List ( String, String )
    , checklistAbove : List ( String, String )
    , checklistBelow : List ( String, String )
    , checkAllButtons : List ( String, String )
    , toggleButton : List ( String, String )
    , checkAllButtonsAbove : List ( String, String )
    , checkAllButtonsBelow : List ( String, String )
    }
css =
    { toggleButton =
        [ ( "width", "100%" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "z-index", "2" )
        , ( "font-size", "16px" )
        , ( "padding-top", "4px" )
        , ( "padding-bottom", "4px" )
        , ( "white-space", "nowrap" )
        , ( "position", "relative" )
        ]
    , checklist =
        [ ( "max-height", "200px" )
        , ( "overflow-y", "auto" )
        , ( "word-wrap", "break-word" )
        , ( "z-index", "1" )
        , ( "left", "0px" )
        , ( "right", "0px" )
        , ( "padding-bottom", "10px" )
        ]
    , checklistAbove =
        [ ( "position", "absolute" )
        , ( "bottom", "27px" )
        ]
    , checklistBelow =
        [ ( "position", "absolute" )
        , ( "top", "27px" )
        ]
    , checkAllButtonsAbove =
        [ ( "position", "relative" )
        , ( "bottom", "52px" )
        , ( "border-bottom", "none" )
        ]
    , checkAllButtonsBelow =
        [ ( "position", "relative" )
        , ( "top", "-1px" )
        ]
    , checkAllButtons =
        [ ( "width", "50%" )
        , ( "height", "25px" )
        , ( "white-space", "nowrap" )
        , ( "text-overflow", "ellipsis" )
        , ( "overflow", "hidden" )
        , ( "font-size", "11px" )
        , ( "z-index", "1" )
        ]
    }
