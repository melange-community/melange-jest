let _ = [%mel.raw {|require('@testing-library/jest-dom')|}]

type expect
type t = Dom.element

module HaveClass = struct
  type options = < exact : bool Js.undefined > Js.t

  external makeOptions : ?exact:bool -> unit -> options = "" [@@mel.obj]
end

module TextContent = struct
  type options = < normalizeWhitespace : bool Js.undefined > Js.t

  external makeOptions : ?normalizeWhitespace:bool -> unit -> options = ""
  [@@mel.obj]
end

external expect : t -> expect = "expect"
external not_ : expect -> expect = "not" [@@mel.get]

let pass : (expect -> unit) -> expect -> Jest.assertion =
 fun assertion expect -> expect |. assertion |. fun _ -> Jest.pass

external _toBeDisabled : (expect[@mel.this]) -> unit = "toBeDisabled"
[@@mel.send]

let toBeDisabled = _toBeDisabled |. pass

external _toBeEnabled : (expect[@mel.this]) -> unit = "toBeEnabled" [@@mel.send]

let toBeEnabled = _toBeEnabled |. pass

external _toBeEmptyDOMElement : (expect[@mel.this]) -> unit
  = "toBeEmptyDOMElement"
[@@mel.send]

let toBeEmptyDOMElement = _toBeEmptyDOMElement |. pass

external _toBeInTheDocument : (expect[@mel.this]) -> unit = "toBeInTheDocument"
[@@mel.send]

let toBeInTheDocument = _toBeInTheDocument |. pass

external _toBeInvalid : (expect[@mel.this]) -> unit = "toBeInvalid" [@@mel.send]

let toBeInvalid = _toBeInvalid |. pass

external _toBeRequired : (expect[@mel.this]) -> unit = "toBeRequired"
[@@mel.send]

let toBeRequired = _toBeRequired |. pass

external _toBeValid : (expect[@mel.this]) -> unit = "toBeValid" [@@mel.send]

let toBeValid = _toBeValid |. pass

external _toBeVisible : (expect[@mel.this]) -> unit = "toBeVisible" [@@mel.send]

let toBeVisible = _toBeVisible |. pass

external _toContainElement : t Js.nullable -> (expect[@mel.this]) -> unit
  = "toContainElement"
[@@mel.send]

let toContainElement element =
  element |. Js.Nullable.fromOption |. _toContainElement |. pass

external _toContainHTML : string -> (expect[@mel.this]) -> unit
  = "toContainHTML"
[@@mel.send]

let toContainHTML html = html |. _toContainHTML |. pass

external _toHaveAttribute :
  string -> string Js.undefined -> (expect[@mel.this]) -> unit
  = "toHaveAttribute"
[@@mel.send]

let toHaveAttribute attribute ?value =
  _toHaveAttribute attribute (Js.Undefined.fromOption value) |. pass

external _toHaveClass :
  string -> HaveClass.options Js.undefined -> (expect[@mel.this]) -> unit
  = "toHaveClass"
[@@mel.send]

let toHaveClass class_ ?options =
  _toHaveClass
    (match class_ with `Str cls -> cls | `Lst lst -> String.concat " " lst)
    (Js.Undefined.fromOption options)
  |. pass

external _toHaveFocus : (expect[@mel.this]) -> unit = "toHaveFocus" [@@mel.send]

let toHaveFocus = _toHaveFocus |. pass

external _toHaveFormValues : < .. > Js.t -> (expect[@mel.this]) -> unit
  = "toHaveFormValues"
[@@mel.send]

let toHaveFormValues values = values |. _toHaveFormValues |. pass

external _toHaveStyle :
  ([ `Str of string | `Obj of < .. > Js.t ][@mel.unwrap]) ->
  (expect[@mel.this]) ->
  unit = "toHaveStyle"
[@@mel.send]

let toHaveStyle style = style |. _toHaveStyle |. pass

external _toHaveTextContent :
  ([ `Str of string | `RegExp of Js.Re.t ][@mel.unwrap]) ->
  TextContent.options Js.undefined ->
  (expect[@mel.this]) ->
  unit = "toHaveTextContent"
[@@mel.send]

let toHaveTextContent content ?options =
  _toHaveTextContent content (Js.Undefined.fromOption options) |. pass

external _toHaveValue :
  ([ `Str of string | `Arr of string array | `Num of int ][@mel.unwrap]) ->
  (expect[@mel.this]) ->
  unit = "toHaveValue"
[@@mel.send]

let toHaveValue value = value |. _toHaveValue |. pass

external _toHaveDisplayValue :
  ([ `Str of string | `RegExp of Js.Re.t | `Arr of string array ][@mel.unwrap]) ->
  (expect[@mel.this]) ->
  unit = "toHaveDisplayValue"
[@@mel.send]

let toHaveDisplayValue value = value |. _toHaveDisplayValue |. pass

external _toBeChecked : (expect[@mel.this]) -> unit = "toBeChecked" [@@mel.send]

let toBeChecked = _toBeChecked |. pass

external _toBePartiallyChecked : (expect[@mel.this]) -> unit
  = "toBePartiallyChecked"
[@@mel.send]

let toBePartiallyChecked = _toBePartiallyChecked |. pass

external _toHaveAccessibleDescription :
  ([ `Str of string | `RegExp of Js.Re.t ][@mel.unwrap]) ->
  (expect[@mel.this]) ->
  unit = "toHaveAccessibleDescription"
[@@mel.send]

let toHaveAccessibleDescription content =
  content |. _toHaveAccessibleDescription |. pass
