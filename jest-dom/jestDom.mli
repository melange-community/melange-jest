type expect
type t = Dom.element

module HaveClass : sig
  type options = < exact : bool Js.undefined > Js.t

  external makeOptions : ?exact:bool -> unit -> options = "" [@@bs.obj]
end

module TextContent : sig
  type options = < normalizeWhitespace : bool Js.undefined > Js.t

  external makeOptions : ?normalizeWhitespace:bool -> unit -> options = ""
    [@@bs.obj]
end

external expect : t -> expect = "expect" [@@bs.val]
external not_ : expect -> expect = "not" [@@bs.get]
val toBeDisabled : expect -> Jest.assertion
val toBeEnabled : expect -> Jest.assertion
val toBeEmptyDOMElement : expect -> Jest.assertion
val toBeInTheDocument : expect -> Jest.assertion
val toBeInvalid : expect -> Jest.assertion
val toBeRequired : expect -> Jest.assertion
val toBeValid : expect -> Jest.assertion
val toBeVisible : expect -> Jest.assertion
val toContainElement : t option -> expect -> Jest.assertion
val toContainHTML : string -> expect -> Jest.assertion
val toHaveAttribute : string -> ?value:string -> expect -> Jest.assertion

val toHaveClass :
  [ `Str of string | `Lst of string list ] ->
  ?options:HaveClass.options ->
  expect ->
  Jest.assertion

val toHaveFocus : expect -> Jest.assertion
val toHaveFormValues : < .. > Js.t -> expect -> Jest.assertion

val toHaveStyle :
  [ `Str of string | `Obj of < .. > Js.t ] -> expect -> Jest.assertion

val toHaveTextContent :
  [ `Str of string | `RegExp of Js.Re.t ] ->
  ?options:TextContent.options ->
  expect ->
  Jest.assertion

val toHaveValue :
  [ `Str of string | `Arr of string array | `Num of int ] ->
  expect ->
  Jest.assertion

val toHaveDisplayValue :
  [ `Str of string | `RegExp of Js.Re.t | `Arr of string array ] ->
  expect ->
  Jest.assertion

val toBeChecked : expect -> Jest.assertion
val toBePartiallyChecked : expect -> Jest.assertion

val toHaveAccessibleDescription :
  [ `Str of string | `RegExp of Js.Re.t ] -> expect -> Jest.assertion
