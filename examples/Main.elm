module Example exposing (main)

import Html exposing (Html, br, div, h2, h4, span, text)
import Html.Attributes exposing (style)
import List
import MultiselectMenu


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { dropupItems : List Item
    , dropupState : MultiselectMenu.State
    , dropdownItems : List ( String, Bool )
    , dropdownState : MultiselectMenu.State
    }


init : ( Model, Cmd Msg )
init =
    ( { dropupItems =
            [ Item 1 False
            , Item 2 False
            , Item 3 False
            , Item 4 False
            ]
      , dropupState = MultiselectMenu.init
      , dropdownItems = [ ( "Apple", False ), ( "Banana", False ), ( "Clementine", False ), ( "Dragon Fruit", False ) ]
      , dropdownState = MultiselectMenu.init
      }
    , Cmd.none
    )


type alias Item =
    { name : Int
    , isChecked : Bool
    }



-- Update


type Msg
    = SetDropupState MultiselectMenu.State
    | ToggleDropupItem Item
    | SelectAllDropup Bool
    | SetDropdownState MultiselectMenu.State
    | ToggleDropdownItem ( String, Bool )
    | SelectAllDropdown Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDropupState newState ->
            ( { model | dropupState = newState }
            , Cmd.none
            )

        ToggleDropupItem item ->
            let
                newItems =
                    List.map
                        (\listItem ->
                            if listItem.name == item.name then
                                Item listItem.name (not listItem.isChecked)
                            else
                                Item listItem.name listItem.isChecked
                        )
                        model.dropupItems
            in
            ( { model | dropupItems = newItems }
            , Cmd.none
            )

        SetDropdownState newState ->
            ( { model | dropdownState = newState }
            , Cmd.none
            )

        ToggleDropdownItem item ->
            ( { model | dropdownItems = MultiselectMenu.toggleItem item model.dropdownItems }
            , Cmd.none
            )

        SelectAllDropup checkAll ->
            ( { model | dropupItems = List.map (\item -> Item item.name checkAll) model.dropupItems }
            , Cmd.none
            )

        SelectAllDropdown check ->
            ( { model | dropdownItems = MultiselectMenu.selectAll check model.dropdownItems }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view { dropupItems, dropupState, dropdownState, dropdownItems } =
    div [ style [ ( "margin-left", "50px" ) ] ]
        [ h2 [] [ text "Example Dropdown Menus:" ]
        , div [ style [ ( "width", "200px" ), ( "display", "inline-block" ), ( "margin", "150px 0px 0px 100px" ) ] ]
            [ MultiselectMenu.view dropupConfig dropupState dropupItems ]
        , div [ style [ ( "width", "150px" ), ( "display", "inline-block" ), ( "margin", "150px 0px 125px 100px" ) ] ]
            [ MultiselectMenu.view dropdownConfig dropdownState dropdownItems ]
        , viewDropupItems dropupItems
        , br [] []
        , viewDropdownItems dropdownItems
        ]


viewDropupItems : List Item -> Html Msg
viewDropupItems itemsList =
    let
        viewItem =
            \item ->
                if item.isChecked then
                    div [] [ text (toString item.name ++ " is checked") ]
                else
                    div [] [ text (toString item.name ++ " is not checked") ]
    in
    div []
        [ h4 [] [ text "Dropup items: " ]
        , div [ style [ ( "margin-left", "50px" ) ] ] (List.map viewItem itemsList)
        ]


viewDropdownItems : List ( String, Bool ) -> Html Msg
viewDropdownItems itemsList =
    let
        viewItem =
            \( name, isChecked ) ->
                if isChecked then
                    div [] [ text (name ++ " is checked") ]
                else
                    div [] [ text (name ++ " is not checked") ]
    in
    div []
        [ h4 [] [ text "Dropdown items: " ]
        , div [ style [ ( "margin-left", "50px" ) ] ] (List.map viewItem itemsList)
        ]



--CONFIG


dropupConfig : MultiselectMenu.Config Item Msg
dropupConfig =
    MultiselectMenu.customConfig
        { displayText = "Dropup Menu"
        , stateToMsg = SetDropupState
        , toggleItem = ToggleDropupItem
        , groupOperations = MultiselectMenu.SelectAll SelectAllDropup
        , displayDirection = MultiselectMenu.Up
        , colors = myColors
        , itemToString = \item -> toString item.name
        , itemToBool = \item -> item.isChecked
        }


dropdownConfig : MultiselectMenu.Config ( String, Bool ) Msg
dropdownConfig =
    MultiselectMenu.customConfig
        { displayText = "Dropdown"
        , stateToMsg = SetDropdownState
        , toggleItem = ToggleDropdownItem
        , groupOperations = MultiselectMenu.SelectAll SelectAllDropdown
        , displayDirection = MultiselectMenu.Down
        , colors = MultiselectMenu.defaultColors
        , itemToString = \item -> Tuple.first item
        , itemToBool = \item -> Tuple.second item
        }


myColors : MultiselectMenu.Colors
myColors =
    { backgroundColor = "#333"
    , backgroundBorder = "#555"
    , buttonColor = "#111"
    , buttonBorder = "#888"
    , textColor = "#ccc"
    }
