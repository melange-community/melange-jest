open Jest
open JestDom
open Webapi.Dom
open Webapi.Dom.Element

let render html =
  let body = Document.createElement "body" document in
  (body |. setInnerHTML) html;
  (document |. Document.unsafeAsHtmlDocument |. HtmlDocument.setBody) body;
  body

let queryByTestId (id : string) (element : Dom.element) =
  match element |> querySelector {j|[data-testid="$(id)"]|j} with
  | Some el -> el
  | None -> raise (Failure "Element not found")

let _ =
  afterEach (fun () ->
      match document |. Document.unsafeAsHtmlDocument |. HtmlDocument.body with
      | Some body -> (body |. setInnerHTML) ""
      | None -> raise (Failure "Not document body found"))

let _ =
  test "toBeDisabled" (fun () ->
      render {|<button disabled data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> toBeDisabled)

let _ =
  test "not toBeDisabled" (fun () ->
      render {|<button data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> not_ |> toBeDisabled)

let _ =
  test "toBeEnabled" (fun () ->
      render {|<button data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> toBeEnabled)

let _ =
  test "not toBeEnabled" (fun () ->
      render {|<button disabled data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> not_ |> toBeEnabled)

let _ =
  test "toBeEmptyDOMElement" (fun () ->
      render {|<button data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> toBeEmptyDOMElement)

let _ =
  test "not toBeEmptyDOMElement" (fun () ->
      render {|<button disabled data-testid="button">Click me</button>|}
      |> queryByTestId "button" |> expect |> not_ |> toBeEmptyDOMElement)

let _ =
  test "toBeInTheDocument" (fun () ->
      render {|<button data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> toBeInTheDocument)

let _ =
  test "not toBeInTheDocument" (fun () ->
      render {|<button></button>|} |> fun _ ->
      Document.createElement "div" document
      |> expect |> not_ |> toBeInTheDocument)

let _ =
  test "toBeInvalid" (fun () ->
      render {|<input required data-testid="input" />|}
      |> queryByTestId "input" |> expect |> toBeInvalid)

let _ =
  test "not toBeInvalid" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_ |> toBeInvalid)

let _ =
  test "toBeRequired" (fun () ->
      render {|<input required data-testid="input" />|}
      |> queryByTestId "input" |> expect |> toBeRequired)

let _ =
  test "not toBeRequired" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_ |> toBeRequired)

let _ =
  test "toBeValid" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> toBeValid)

let _ =
  test "not toBeValid" (fun () ->
      render {|<input required data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_ |> toBeValid)

let _ =
  test "toBeVisible" (fun () ->
      render {|<button data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> toBeVisible)

let _ =
  test "not toBeVisible" (fun () ->
      render {|<button style="display: none" data-testid="button"></button>|}
      |> queryByTestId "button" |> expect |> not_ |> toBeVisible)

let _ =
  test "toContainElement" (fun () ->
      let element =
        render {|<span data-testid="span"><button></button></span>|}
      in
      element |> queryByTestId "span" |> expect
      |> (("button" |. querySelector) (document |. Document.documentElement)
         |. toContainElement))

let _ =
  test "not toContainElement" (fun () ->
      let element = render {|<span data-testid="span"></span>|} in
      element |> queryByTestId "span" |> expect |> not_
      |> (("div" |. Document.createElement) document |. Some |. toContainElement))

let _ =
  test "toContainHTML" (fun () ->
      render {|<span data-testid="span"><p></p></span>|}
      |> queryByTestId "span" |> expect |> toContainHTML "<p></p>")

let _ =
  test "not toContainHTML" (fun () ->
      render {|<span data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_ |> toContainHTML "<p></p>")

let _ =
  test "toHaveAttribute" (fun () ->
      render {|<span class="empty" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> toHaveAttribute "class")

let _ =
  test "not toHaveAttribute" (fun () ->
      render {|<span data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_ |> toHaveAttribute "class")

let _ =
  test "toHaveAttribute with value" (fun () ->
      render {|<span class="empty" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveAttribute "class" ~value:"empty")

let _ =
  test "not toHaveAttribute with value" (fun () ->
      render {|<span class="hidden" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveAttribute "class" ~value:"empty")

let _ =
  test "toHaveClass (string)" (fun () ->
      render {|<span class="empty" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveClass (`Str "empty"))

let _ =
  test "not toHaveClass (string)" (fun () ->
      render {|<span data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveClass (`Str "empty"))

let _ =
  test "toHaveClass (list)" (fun () ->
      render {|<span class="empty hidden" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveClass (`Lst [ "empty"; "hidden" ]))

let _ =
  test "not toHaveClass (list)" (fun () ->
      render {|<span class="hidden" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveClass (`Lst [ "empty"; "hidden" ]))

let _ =
  test "toHaveClass (string) [exact]" (fun () ->
      render {|<span class="empty hidden" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveClass (`Str "empty hidden")
           ~options:(HaveClass.makeOptions ~exact:true ()))

let _ =
  test "not toHaveClass (string) [exact]" (fun () ->
      render {|<span class="hidden" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveClass (`Str "empty")
           ~options:(HaveClass.makeOptions ~exact:true ()))

let _ =
  test "toHaveFocus" (fun () ->
      let element = render {|<span tabindex="1" data-testid="span"></span>|} in
      ("span" |. queryByTestId) element
      |. Element.unsafeAsHtmlElement |. HtmlElement.focus;
      element |> queryByTestId "span" |> expect |> toHaveFocus)

let _ =
  test "not toHaveFocus" (fun () ->
      render {|<span data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_ |> toHaveFocus)

let _ =
  test "toHaveFormValues" (fun () ->
      render
        {|<form data-testid="form"><label for="title">Job title</label><input type="text" id="title" name="title" value="CEO" /></form>|}
      |> queryByTestId "form" |> expect
      |> toHaveFormValues [%mel.obj { title = "CEO" }])

let _ =
  test "not toHaveFormValues" (fun () ->
      render
        {|<form data-testid="form"><label for="title">Job title</label><input type="text" id="title" name="title" value="CEO" /></form>|}
      |> queryByTestId "form" |> expect |> not_
      |> toHaveFormValues [%mel.obj { title = "CTO" }])

let _ =
  test "toHaveStyle (string)" (fun () ->
      render {|<span style="color: rebeccapurple" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveStyle (`Str "color: rebeccapurple"))

let _ =
  test "not toHaveStyle (string)" (fun () ->
      render {|<span style="display: none" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveStyle (`Str "display: inline-block"))

let _ =
  test "toHaveStyle (object)" (fun () ->
      render {|<span style="color: rebeccapurple" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect
      |> toHaveStyle (`Obj [%mel.obj { color = "rebeccapurple" }]))

let _ =
  test "not toHaveStyle (object)" (fun () ->
      render {|<span style="display: none" data-testid="span"></span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveStyle (`Obj [%mel.obj { display = "inline-block" }]))

let _ =
  test "toHaveTextContent (string)" (fun () ->
      render {|<span data-testid="span">Step 1 of 4</span>|}
      |> queryByTestId "span" |> expect
      |> toHaveTextContent (`Str "Step 1 of 4"))

let _ =
  test "not toHaveTextContent (string)" (fun () ->
      render {|<span data-testid="span">Step 2 of 4</span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveTextContent (`Str "Step 1 of 4"))

let _ =
  test "toHaveTextContent (string) with options" (fun () ->
      render {|<span data-testid="span">&nbsp;&nbsp;Step 1 of 4</span>|}
      |> queryByTestId "span" |> expect
      |> toHaveTextContent (`Str "  Step 1 of 4")
           ~options:(TextContent.makeOptions ~normalizeWhitespace:false ()))

let _ =
  test "toHaveTextContent (regex)" (fun () ->
      render {|<span data-testid="span">Step 1 of 4</span>|}
      |> queryByTestId "span" |> expect
      |> toHaveTextContent (`RegExp [%mel.re "/Step \\d of \\d/"]))

let _ =
  test "not toHaveTextContent (regex)" (fun () ->
      render {|<span data-testid="span">Step 2 of 4</span>|}
      |> queryByTestId "span" |> expect |> not_
      |> toHaveTextContent (`RegExp [%mel.re "/^\\d of 4$/"]))

let _ =
  test "toHaveValue (string)" (fun () ->
      render {|<input data-testid="input" value="5" />|}
      |> queryByTestId "input" |> expect
      |> toHaveValue (`Str "5"))

let _ =
  test "not toHaveValue (string)" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_
      |> toHaveValue (`Str "5"))

let _ =
  test "toHaveValue (num)" (fun () ->
      render {|<input type="number" data-testid="input" value="5" />|}
      |> queryByTestId "input" |> expect
      |> toHaveValue (`Num 5))

let _ =
  test "not toHaveValue (num)" (fun () ->
      render {|<input type="number" data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_
      |> toHaveValue (`Num 5))

let _ =
  test "toHaveValue (array)" (fun () ->
      render
        {|<select data-testid="select" multiple><option value=""></option><option value="apple" selected>Apple</option><option value="peach">Peach</option><option value="orange" selected>Orange</option></select>|}
      |> queryByTestId "select" |> expect
      |> toHaveValue (`Arr [| "apple"; "orange" |]))

let _ =
  test "not toHaveValue (list)" (fun () ->
      render
        {|<select data-testid="select" multiple><option value=""></option><option value="apple" selected>Apple</option><option value="peach">Peach</option><option value="orange" selected>Orange</option></select>|}
      |> queryByTestId "select" |> expect |> not_
      |> toHaveValue (`Arr [| "apple"; "peach" |]))

let _ =
  test "toHaveDisplayValue (string)" (fun () ->
      render {|<input data-testid="input" value="Test" />|}
      |> queryByTestId "input" |> expect
      |> toHaveDisplayValue (`Str "Test"))

let _ =
  test "not toHaveDisplayValue (string)" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_
      |> toHaveDisplayValue (`Str "Test"))

let _ =
  test "toHaveDisplayValue (regex)" (fun () ->
      render {|<input data-testid="input" value="Test" />|}
      |> queryByTestId "input" |> expect
      |> toHaveDisplayValue (`RegExp [%mel.re "/^Te/"]))

let _ =
  test "not toHaveDisplayValue (regex)" (fun () ->
      render {|<input data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_
      |> toHaveDisplayValue (`RegExp [%mel.re "/Tt/"]))

let _ =
  test "toHaveDisplayValue (array)" (fun () ->
      render
        {|<select data-testid="select" multiple><option value=""></option><option value="apple" selected>Apple</option><option value="peach">Peach</option><option value="orange" selected>Orange</option></select>|}
      |> queryByTestId "select" |> expect
      |> toHaveDisplayValue (`Arr [| "Apple"; "Orange" |]))

let _ =
  test "not toHaveDisplayValue (array)" (fun () ->
      render
        {|<select data-testid="select" multiple><option value=""></option><option value="apple" selected>Apple</option><option value="peach">Peach</option><option value="orange" selected>Orange</option></select>|}
      |> queryByTestId "select" |> expect |> not_
      |> toHaveDisplayValue (`Arr [| "Apple"; "Peach" |]))

let _ =
  test "toBeChecked" (fun () ->
      render {|<input type="checkbox" checked data-testid="input" />|}
      |> queryByTestId "input" |> expect |> toBeChecked)

let _ =
  test "not toBeChecked" (fun () ->
      render {|<input type="checkbox" data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_ |> toBeChecked)

let _ =
  test "toBePartiallyChecked" (fun () ->
      render
        {|<input type="checkbox" aria-checked="mixed" data-testid="input" />|}
      |> queryByTestId "input" |> expect |> toBePartiallyChecked)

let _ =
  test "not toBePartiallyChecked" (fun () ->
      render {|<input type="checkbox" checked data-testid="input" />|}
      |> queryByTestId "input" |> expect |> not_ |> toBePartiallyChecked)

let _ =
  test "toHaveAccessibleDescription (string)" (fun () ->
      render
        {|<span><button data-testid="button" aria-label="Close" aria-describedby="description-close">X</button><div id="description-close">Closing will discard any changes</div></span>|}
      |> queryByTestId "button" |> expect
      |> toHaveAccessibleDescription (`Str "Closing will discard any changes"))

let _ =
  test "not toHaveAccessibleDescription (string)" (fun () ->
      render
        {|<span><button data-testid="button" aria-label="Close" aria-describedby="description-close">X</button><div id="description-close">Closing will discard any changes</div></span>|}
      |> queryByTestId "button" |> expect |> not_
      |> toHaveAccessibleDescription (`Str "Other description"))

let _ =
  test "toHaveAccessibleDescription (regex)" (fun () ->
      render
        {|<span><button data-testid="button" aria-label="Close" aria-describedby="description-close">X</button><div id="description-close">Closing will discard any changes</div></span>|}
      |> queryByTestId "button" |> expect
      |> toHaveAccessibleDescription (`RegExp [%mel.re "/will discard/"]))

let _ =
  test "not toHaveAccessibleDescription (regex)" (fun () ->
      render
        {|<span><button data-testid="button" aria-label="Close" aria-describedby="description-close">X</button><div id="description-close">Closing will discard any changes</div></span>|}
      |> queryByTestId "button" |> expect |> not_
      |> toHaveAccessibleDescription (`RegExp [%mel.re "/^Other/"]))
