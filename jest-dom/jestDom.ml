[%%mel.raw {|import '@testing-library/jest-dom'|}]

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

external _toBeDisabled : unit = "toBeDisabled" [@@mel.send.pipe: expect]

let toBeDisabled = _toBeDisabled |. pass

external _toBeEnabled : unit = "toBeEnabled" [@@mel.send.pipe: expect]

let toBeEnabled = _toBeEnabled |. pass

external _toBeEmptyDOMElement : unit = "toBeEmptyDOMElement"
  [@@mel.send.pipe: expect]

let toBeEmptyDOMElement = _toBeEmptyDOMElement |. pass

external _toBeInTheDocument : unit = "toBeInTheDocument"
  [@@mel.send.pipe: expect]

let toBeInTheDocument = _toBeInTheDocument |. pass

external _toBeInvalid : unit = "toBeInvalid" [@@mel.send.pipe: expect]

let toBeInvalid = _toBeInvalid |. pass

external _toBeRequired : unit = "toBeRequired" [@@mel.send.pipe: expect]

let toBeRequired = _toBeRequired |. pass

external _toBeValid : unit = "toBeValid" [@@mel.send.pipe: expect]

let toBeValid = _toBeValid |. pass

external _toBeVisible : unit = "toBeVisible" [@@mel.send.pipe: expect]

let toBeVisible = _toBeVisible |. pass

external _toContainElement : t Js.nullable -> unit = "toContainElement"
  [@@mel.send.pipe: expect]

let toContainElement element =
  element |. Js.Nullable.fromOption |. _toContainElement |. pass

external _toContainHTML : string -> unit = "toContainHTML"
  [@@mel.send.pipe: expect]

let toContainHTML html = html |. _toContainHTML |. pass

external _toHaveAttribute : string -> string Js.undefined -> unit
  = "toHaveAttribute"
  [@@mel.send.pipe: expect]

let toHaveAttribute attribute ?value =
  _toHaveAttribute attribute (Js.Undefined.fromOption value) |. pass

external _toHaveClass : string -> HaveClass.options Js.undefined -> unit
  = "toHaveClass"
  [@@mel.send.pipe: expect]

let toHaveClass class_ ?options =
  _toHaveClass
    (match class_ with `Str cls -> cls | `Lst lst -> String.concat " " lst)
    (Js.Undefined.fromOption options)
  |. pass

external _toHaveFocus : unit = "toHaveFocus" [@@mel.send.pipe: expect]

let toHaveFocus = _toHaveFocus |. pass

external _toHaveFormValues : < .. > Js.t -> unit = "toHaveFormValues"
  [@@mel.send.pipe: expect]

let toHaveFormValues values = values |. _toHaveFormValues |. pass

external _toHaveStyle :
  ([ `Str of string | `Obj of < .. > Js.t ][@mel.unwrap]) -> unit = "toHaveStyle"
  [@@mel.send.pipe: expect]

let toHaveStyle style = style |. _toHaveStyle |. pass

external _toHaveTextContent :
  ([ `Str of string | `RegExp of Js.Re.t ][@mel.unwrap]) ->
  TextContent.options Js.undefined ->
  unit = "toHaveTextContent"
  [@@mel.send.pipe: expect]

let toHaveTextContent content ?options =
  _toHaveTextContent content (Js.Undefined.fromOption options) |. pass

external _toHaveValue :
  ([ `Str of string | `Arr of string array | `Num of int ][@mel.unwrap]) -> unit
  = "toHaveValue"
  [@@mel.send.pipe: expect]

let toHaveValue value = value |. _toHaveValue |. pass

external _toHaveDisplayValue :
  ([ `Str of string | `RegExp of Js.Re.t | `Arr of string array ][@mel.unwrap]) ->
  unit = "toHaveDisplayValue"
  [@@mel.send.pipe: expect]

let toHaveDisplayValue value = value |. _toHaveDisplayValue |. pass

external _toBeChecked : unit = "toBeChecked" [@@mel.send.pipe: expect]

let toBeChecked = _toBeChecked |. pass

external _toBePartiallyChecked : unit = "toBePartiallyChecked"
  [@@mel.send.pipe: expect]

let toBePartiallyChecked = _toBePartiallyChecked |. pass

external _toHaveAccessibleDescription :
  ([ `Str of string | `RegExp of Js.Re.t ][@mel.unwrap]) -> unit
  = "toHaveAccessibleDescription"
  [@@mel.send.pipe: expect]

let toHaveAccessibleDescription content = content |. _toHaveAccessibleDescription |. pass
