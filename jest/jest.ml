type 'a modifier = [ `Just of 'a | `Not of 'a ]

let mapMod f = function `Just a -> `Just (f a) | `Not a -> `Not (f a)

type assertion =
  | Ok : assertion
  | Fail : string -> assertion
  | ArrayContains : ('a array * 'a) modifier -> assertion
  | ArrayContainsEqual : ('a array * 'a) modifier -> assertion
  | ArrayLength : ('a array * int) modifier -> assertion
  | ArraySuperset : ('a array * 'a array) modifier -> assertion
  | Be : ('a * 'a) modifier -> assertion
  | Equal : ('a * 'a) modifier -> assertion
  | FloatCloseTo : (float * float * int option) modifier -> assertion
  | GreaterThan : ('a * 'a) modifier -> assertion
  | GreaterThanOrEqual : ('a * 'a) modifier -> assertion
  | LessThan : ('a * 'a) modifier -> assertion
  | LessThanOrEqual : ('a * 'a) modifier -> assertion
  | StringContains : (string * string) modifier -> assertion
  | StringMatch : (string * Js.Re.t) modifier -> assertion
  | Throws : (unit -> _) modifier -> assertion
  | MatchInlineSnapshot : _ * string -> assertion
  | MatchSnapshot : _ -> assertion
  | MatchSnapshotName : _ * string -> assertion
  | ThrowsMatchSnapshot : (unit -> _) -> assertion
  (* JS *)
  | Defined : 'a Js.undefined modifier -> assertion
  | Falsy : 'a modifier -> assertion
  | Null : _ Js.null modifier -> assertion
  | Truthy : 'a modifier -> assertion
  | Undefined : 'a Js.undefined modifier -> assertion
  | ObjectContains : (< .. > Js.t * string array) modifier -> assertion
  | ObjectMatch : (< .. > Js.t * < .. > Js.t) modifier -> assertion

module type Asserter = sig
  type 'a t

  val affirm : 'a t -> unit
end

external inputAsString : 'a -> string = "%identity"

(* internal *)
module LLExpect : sig
  type 'a t = assertion

  val affirm : 'a t -> unit
end = struct
  type 'a t = assertion
  type specialMatch

  external expect : 'a -> < .. > Js.t = "expect"
  external fail : string -> unit = "fail"
  external arrayContaining : 'a array -> specialMatch = "expect.arrayContaining"
  external stringContaining : string -> specialMatch = "expect.stringContaining"

  let objectContaining : string array -> < .. > Js.t =
    [%raw
      {|
    function (properties) {
      var spec = {};
      properties.forEach(function (property) {
        spec[property] = expect.anything();
      });
      return spec;
    }
  |}]

  let affirm = function
    | Ok -> ()
    | Fail message -> fail message
    | ArrayContains (`Just (a, b)) -> (expect a)##toContain b
    | ArrayContains (`Not (a, b)) -> (expect a)##not##toContain b
    | ArrayContainsEqual (`Just (a, b)) -> (expect a)##toContainEqual b
    | ArrayContainsEqual (`Not (a, b)) -> (expect a)##not##toContainEqual b
    | ArrayLength (`Just (a, l)) -> (expect a)##toHaveLength l
    | ArrayLength (`Not (a, l)) -> (expect a)##not##toHaveLength l
    | ArraySuperset (`Just (a, b)) -> (expect a)##toEqual (arrayContaining b)
    | ArraySuperset (`Not (a, b)) ->
        (expect a)##not##toEqual (arrayContaining b)
    | Be (`Just (a, b)) -> (expect a)##toBe b
    | Be (`Not (a, b)) -> (expect a)##not##toBe b
    | Equal (`Just (a, b)) -> (expect a)##toEqual b
    | Equal (`Not (a, b)) -> (expect a)##not##toEqual b
    | FloatCloseTo (`Just (a, b, p)) ->
        (expect a)##toBeCloseTo b (Js.Undefined.fromOption p)
    | FloatCloseTo (`Not (a, b, p)) ->
        (expect a)##not##toBeCloseTo b (Js.Undefined.fromOption p)
    | GreaterThan (`Just (a, b)) -> (expect a)##toBeGreaterThan b
    | GreaterThan (`Not (a, b)) -> (expect a)##not##toBeGreaterThan b
    | GreaterThanOrEqual (`Just (a, b)) -> (expect a)##toBeGreaterThanOrEqual b
    | GreaterThanOrEqual (`Not (a, b)) ->
        (expect a)##not##toBeGreaterThanOrEqual b
    | LessThan (`Just (a, b)) -> (expect a)##toBeLessThan b
    | LessThan (`Not (a, b)) -> (expect a)##not##toBeLessThan b
    | LessThanOrEqual (`Just (a, b)) -> (expect a)##toBeLessThanOrEqual b
    | LessThanOrEqual (`Not (a, b)) -> (expect a)##not##toBeLessThanOrEqual b
    | StringMatch (`Just (s, re)) -> (expect s)##toMatch re
    | StringMatch (`Not (s, re)) -> (expect s)##not##toMatch re
    | StringContains (`Just (a, b)) -> (expect a)##toEqual (stringContaining b)
    | StringContains (`Not (a, b)) ->
        (expect a)##not##toEqual (stringContaining b)
    | Throws (`Just f) -> (expect f)##toThrow ()
    | Throws (`Not f) -> (expect f)##not##toThrow ()
    | MatchInlineSnapshot (a, inlineSnapshot) ->
        (expect a)##toMatchInlineSnapshot inlineSnapshot
    | MatchSnapshot a -> (expect a)##toMatchSnapshot ()
    | MatchSnapshotName (a, name) -> (expect a)##toMatchSnapshot name
    | ThrowsMatchSnapshot f -> (expect f)##toThrowErrorMatchingSnapshot ()
    (* JS *)
    | Defined (`Just a) -> (expect a)##toBeDefined ()
    | Defined (`Not a) -> (expect a)##not##toBeDefined ()
    | Falsy (`Just a) -> (expect a)##toBeFalsy ()
    | Falsy (`Not a) -> (expect a)##not##toBeFalsy ()
    | Null (`Just a) -> (expect a)##toBeNull ()
    | Null (`Not a) -> (expect a)##not##toBeNull ()
    | Truthy (`Just a) -> (expect a)##toBeTruthy ()
    | Truthy (`Not a) -> (expect a)##not##toBeTruthy ()
    | Undefined (`Just a) -> (expect a)##toBeUndefined ()
    | Undefined (`Not a) -> (expect a)##not##toBeUndefined ()
    | ObjectContains (`Just (a, props)) ->
        (expect a)##toEqual (objectContaining props)
    | ObjectContains (`Not (a, props)) ->
        (expect a)##not##toEqual (objectContaining props)
    | ObjectMatch (`Just (a, b)) -> (expect a)##toMatchObject b
    | ObjectMatch (`Not (a, b)) -> (expect a)##not##toMatchObject b
end

module Runner (A : Asserter) = struct
  let affirm = A.affirm

  external _test : string -> ((unit -> unit Js.undefined)[@mel.uncurry]) -> unit
    = "test"

  external _testAsync :
    string ->
    (((unit -> unit)[@u]) -> unit Js.undefined) ->
    int Js.Undefined.t ->
    unit = "test"

  external _testPromise :
    string ->
    ((unit -> 'a Js.Promise.t)[@mel.uncurry]) ->
    int Js.Undefined.t ->
    unit = "test"

  let test name callback =
    _test name (fun () ->
        affirm @@ callback ();
        Js.undefined)

  let testAsync name ?timeout callback =
    _testAsync name
      (fun finish ->
        callback (fun case ->
            affirm case;
            finish () [@u]);
        Js.undefined)
      (Js.Undefined.fromOption timeout)

  let testPromise name ?timeout callback =
    _testPromise name
      (fun () ->
        callback ()
        |> Js.Promise.then_ (fun a -> a |> A.affirm |> Js.Promise.resolve))
      (Js.Undefined.fromOption timeout)

  let testAll name inputs callback =
    inputs
    |> List.iter (fun input ->
           let name =
             let input = inputAsString input in
             {j|$name - $input|j}
           in
           _test name (fun () ->
               affirm @@ callback input;
               Js.undefined))

  external describe :
    string -> ((unit -> unit Js.undefined)[@mel.uncurry]) -> unit = "describe"

  let describe label f =
    describe label (fun () ->
        f ();
        Js.undefined)

  external beforeAll : ((unit -> unit)[@mel.uncurry]) -> unit = "beforeAll"

  external beforeAllAsync :
    (((unit -> unit)[@u]) -> unit Js.undefined) -> int Js.Undefined.t -> unit
    = "beforeAll"

  let beforeAllAsync ?timeout callback =
    beforeAllAsync
      (fun finish ->
        callback (fun () -> (finish () [@u]));
        Js.undefined)
      (Js.Undefined.fromOption timeout)

  external beforeAllPromise :
    ((unit -> 'a Js.Promise.t)[@mel.uncurry]) -> int Js.Undefined.t -> unit
    = "beforeAll"

  let beforeAllPromise ?timeout callback =
    beforeAllPromise
      (fun () -> callback () |> Js.Promise.resolve)
      (Js.Undefined.fromOption timeout)

  external beforeEach : ((unit -> unit)[@mel.uncurry]) -> unit = "beforeEach"

  external beforeEachAsync :
    (((unit -> unit)[@u]) -> unit Js.undefined) -> int Js.Undefined.t -> unit
    = "beforeEach"

  let beforeEachAsync ?timeout callback =
    beforeEachAsync
      (fun finish ->
        callback (fun () -> (finish () [@u]));
        Js.undefined)
      (Js.Undefined.fromOption timeout)

  external beforeEachPromise :
    ((unit -> 'a Js.Promise.t)[@mel.uncurry]) -> int Js.Undefined.t -> unit
    = "beforeEach"

  let beforeEachPromise ?timeout callback =
    beforeEachPromise
      (fun () -> callback () |> Js.Promise.resolve)
      (Js.Undefined.fromOption timeout)

  external afterAll : ((unit -> unit)[@mel.uncurry]) -> unit = "afterAll"

  external afterAllAsync :
    (((unit -> unit)[@u]) -> unit Js.undefined) -> int Js.Undefined.t -> unit
    = "afterAll"

  let afterAllAsync ?timeout callback =
    afterAllAsync
      (fun finish ->
        callback (fun () -> (finish () [@u]));
        Js.undefined)
      (Js.Undefined.fromOption timeout)

  external afterAllPromise :
    ((unit -> 'a Js.Promise.t)[@mel.uncurry]) -> int Js.Undefined.t -> unit
    = "afterAll"

  let afterAllPromise ?timeout callback =
    afterAllPromise
      (fun () -> callback () |> Js.Promise.resolve)
      (Js.Undefined.fromOption timeout)

  external afterEach : ((unit -> unit)[@mel.uncurry]) -> unit = "afterEach"

  external afterEachAsync :
    (((unit -> unit)[@u]) -> unit Js.undefined) -> int Js.Undefined.t -> unit
    = "afterEach"

  let afterEachAsync ?timeout callback =
    afterEachAsync
      (fun finish ->
        callback (fun () -> (finish () [@u]));
        Js.undefined)
      (Js.Undefined.fromOption timeout)

  external afterEachPromise :
    ((unit -> 'a Js.Promise.t)[@mel.uncurry]) -> int Js.Undefined.t -> unit
    = "afterEach"

  let afterEachPromise ?timeout callback =
    afterEachPromise
      (fun () -> callback () |> Js.Promise.resolve)
      (Js.Undefined.fromOption timeout)

  module Only = struct
    external _test :
      string -> ((unit -> unit Js.undefined)[@mel.uncurry]) -> unit = "it.only"

    external _testAsync :
      string ->
      (((unit -> unit)[@u]) -> unit Js.undefined) ->
      int Js.Undefined.t ->
      unit = "it.only"

    external _testPromise :
      string ->
      ((unit -> 'a Js.Promise.t)[@mel.uncurry]) ->
      int Js.Undefined.t ->
      unit = "it.only"

    let test name callback =
      _test name (fun () ->
          affirm @@ callback ();
          Js.undefined)

    let testAsync name ?timeout callback =
      _testAsync name
        (fun finish ->
          callback (fun assertion ->
              affirm assertion;
              finish () [@u]);
          Js.undefined)
        (Js.Undefined.fromOption timeout)

    let testPromise name ?timeout callback =
      _testPromise name
        (fun () ->
          callback ()
          |> Js.Promise.then_ (fun a -> a |> affirm |> Js.Promise.resolve))
        (Js.Undefined.fromOption timeout)

    let testAll name inputs callback =
      inputs
      |> List.iter (fun input ->
             let name =
               let input : string = inputAsString input in
               {j|$name - $input|j}
             in
             _test name (fun () ->
                 affirm @@ callback input;
                 Js.undefined))

    external describe :
      string -> ((unit -> unit Js.undefined)[@mel.uncurry]) -> unit
      = "describe.only"

    let describe label f =
      describe label (fun () ->
          f ();
          Js.undefined)
  end

  module Skip = struct
    external test : string -> ((unit -> 'a A.t)[@mel.uncurry]) -> unit
      = "it.skip"

    external testAsync : string -> (('a A.t -> unit) -> unit) -> unit
      = "it.skip"

    let testAsync name ?timeout:_ callback = testAsync name callback

    external testPromise :
      string -> ((unit -> 'a A.t Js.Promise.t)[@mel.uncurry]) -> unit
      = "it.skip"

    let testPromise name ?timeout:_ callback = testPromise name callback

    let testAll name inputs callback =
      inputs
      |> List.iter (fun input ->
             let name =
               let input : string = inputAsString input in
               {j|$name - $input|j}
             in
             test name (fun () -> callback input))

    external describe :
      string -> ((unit -> unit Js.undefined)[@mel.uncurry]) -> unit
      = "describe.skip"

    let describe label f =
      describe label (fun () ->
          f ();
          Js.undefined)
  end

  module Todo = struct
    external test : string -> unit = "it.todo"
  end
end

include Runner (LLExpect)

let pass = Ok
let fail message = Fail message
(*
 * Not implemented:
 * - expect.anything - pointless when there's `option`, `Js.null` etc.
 * - expect.any - pointless when you have types, except against < .. > Js.t, but how to implement this?
 * - expect.arrayContaining - implement as overloads of `toEqual`, `toBeCalledWith`, `objectContaining` and `toMatchObject`
 * - expect.assertions - Not supported. There should be only one assertion per test.
 * - expect.objectContaining - implement as separate matcher and overload of `toBeCalledWith`
 * - expect.stringContaining - implement as overloads of `toEqual`, `toBeCalledWith`, `objectContaining` and `toMatchObject`
 * - expect.stringMatching - implement as overloads of `toEqual`, `toBeCalledWith`, `objectContaining` and `toMatchObject`
 *)

module Expect = struct
  type 'a plainPartial = [ `Just of 'a ]
  type 'a invertedPartial = [ `Not of 'a ]
  type 'a partial = 'a modifier

  let expect a = `Just a
  let expectFn f a = `Just (fun () -> f a)
  let toBe b p = Be (mapMod (fun a -> (a, b)) p)

  (* toHaveBeenCalled* *)

  let toBeCloseTo b p = FloatCloseTo (mapMod (fun a -> (a, b, None)) p)

  let toBeSoCloseTo b ~digits p =
    FloatCloseTo (mapMod (fun a -> (a, b, Some digits)) p)

  let toBeGreaterThan b p = GreaterThan (mapMod (fun a -> (a, b)) p)

  let toBeGreaterThanOrEqual b p =
    GreaterThanOrEqual (mapMod (fun a -> (a, b)) p)

  let toBeLessThan b p = LessThan (mapMod (fun a -> (a, b)) p)
  let toBeLessThanOrEqual b p = LessThanOrEqual (mapMod (fun a -> (a, b)) p)

  (** replaces expect.arrayContaining *)
  let toBeSupersetOf b p = ArraySuperset (mapMod (fun a -> (a, b)) p)

  let toContain b p = ArrayContains (mapMod (fun a -> (a, b)) p)
  let toContainEqual b p = ArrayContainsEqual (mapMod (fun a -> (a, b)) p)

  (** replaces expect.stringContaining *)
  let toContainString b p = StringContains (mapMod (fun a -> (a, b)) p)

  let toEqual b p = Equal (mapMod (fun a -> (a, b)) p)
  let toHaveLength l p = ArrayLength (mapMod (fun a -> (a, l)) p)
  let toMatch s p = StringMatch (mapMod (fun a -> (a, Js.Re.fromString s)) p)

  let toMatchInlineSnapshot inlineSnapshot (`Just a) =
    MatchInlineSnapshot (a, inlineSnapshot)

  let toMatchRe re p = StringMatch (mapMod (fun a -> (a, re)) p)
  let toMatchSnapshot (`Just a) = MatchSnapshot a
  let toMatchSnapshotWithName name (`Just a) = MatchSnapshotName (a, name)
  let toThrow f = Throws (f :> _ modifier)
  let toThrowErrorMatchingSnapshot (`Just f) = ThrowsMatchSnapshot f
  let not_ (`Just a) = `Not a

  let not__ =
    not_ (* For Reason syntax compatibility. TODO: deprecate and remove *)

  module Operators = struct
    (** experimental *)

    let ( == ) = fun a b -> toBe b a
    let ( > ) = fun a b -> toBeGreaterThan b a
    let ( >= ) = fun a b -> toBeGreaterThanOrEqual b a
    let ( < ) = fun a b -> toBeLessThan b a
    let ( <= ) = fun a b -> toBeLessThanOrEqual b a
    let ( = ) = fun a b -> toEqual b a
    let ( <> ) = fun a b -> a |> not_ |> toEqual b
    let ( != ) = fun a b -> a |> not_ |> toBe b
  end
end

module ExpectJs = struct
  include Expect

  let toBeDefined a = Defined (a :> _ modifier)
  let toBeFalsy a = Falsy (a :> _ modifier)

  (* toBeInstanceOf *)
  let toBeNull a = Null (a :> _ modifier)
  let toBeTruthy a = Truthy (a :> _ modifier)
  let toBeUndefined a = Undefined (a :> _ modifier)

  (** replaces expect.objectContaining *)
  let toContainProperties props p =
    ObjectContains (mapMod (fun a -> (a, props)) p)

  let toMatchObject b p = ObjectMatch (mapMod (fun a -> (a, b)) p)
end

module MockJs = struct
  (** experimental *)

  type ('fn, 'args, 'ret) fn

  [%%mel.raw
  {|
    function makeNewMock(self) {
      return new (Function.prototype.bind.apply(self, arguments));
    }
  |}]

  external new0 : (unit -> 'ret, unit, 'ret) fn -> 'ret = "makeNewMock"

  let new0 = new0

  external new1 : ('a -> 'ret, 'a, 'ret) fn -> 'a -> 'ret = "makeNewMock"

  let new1 a self = new1 self a

  external new2 : (('a -> 'b -> 'ret[@u]), 'a * 'b, 'ret) fn -> 'a -> 'b -> 'ret
    = "makeNewMock"

  let new2 a b self = new2 self a b

  external fn : ('fn, _, _) fn -> 'fn = "%identity"

  external calls : (_, 'args, _) fn -> 'args array = "calls"
  [@@mel.get] [@@mel.scope "mock"]

  let calls self = Js.Array.copy (calls self)
  (* Awesome, the bloody things are mutated so we need to copy *)

  let calls self =
    calls self
    |> Array.map
         [%mel.raw
           {|
    function (args) { return args.length === 1 ? args[0] : args }
  |}]
  (* there's no such thing as aa 1-ary tuple, so we need to unbox single-element arrays *)

  external instances : (_, _, 'ret) fn -> 'ret array = "instances"
  [@@mel.get] [@@mel.scope "mock"]
  (* TODO: semms this only records "instances" created by `new` *)

  let instances self = Js.Array.copy (instances self)
  (* Awesome, the bloody things are mutated so we need to copy *)

  external mockClear : (_ fn[@mel.this]) -> unit = "mockClear"
  [@@mel.send]
  (** Beware: this actually replaces `mock`, not just `mock.instances` and
      `mock.calls` *)

  external mockReset : (_ fn[@mel.this]) -> unit = "mockReset" [@@mel.send]

  external mockImplementation :
    'fn -> ((('fn, _, _) fn as 'self)[@mel.this]) -> 'self
    = "mockImplementation"
  [@@mel.send]

  external mockImplementationOnce :
    'fn -> ((('fn, _, _) fn as 'self)[@mel.this]) -> 'self
    = "mockImplementationOnce"
  [@@mel.send]

  external mockReturnThis : ((_, _, 'ret) fn[@mel.this]) -> unit
    = "mockReturnThis"
  [@@mel.send]
  (* not type safe, we don't know what `this` actually is *)

  external mockReturnValue :
    'ret -> (((_, _, 'ret) fn as 'self)[@mel.this]) -> 'self = "mockReturnValue"
  [@@mel.send]

  external mockReturnValueOnce :
    'ret -> (((_, _, 'ret) fn as 'self)[@mel.this]) -> 'self
    = "mockReturnValueOnce"
  [@@mel.send]
end

module Jest = struct
  external clearAllTimers : unit -> unit = "jest.clearAllTimers"
  external runAllTicks : unit -> unit = "jest.runAllTicks"
  external runAllTimers : unit -> unit = "jest.runAllTimers"
  external runAllImmediates : unit -> unit = "jest.runAllImmediates"
  external advanceTimersByTime : int -> unit = "jest.advanceTimersByTime"
  external runOnlyPendingTimers : unit -> unit = "jest.runOnlyPendingTimers"

  type fakeTimersConfig = { legacyFakeTimers : bool }

  external useFakeTimers : ?config:fakeTimersConfig -> unit -> unit
    = "jest.useFakeTimers"

  external useRealTimers : unit -> unit = "jest.useRealTimers"
end

module JestJs = struct
  (** experimental *)

  external disableAutomock : unit -> unit = "jest.disableAutomock"
  external enableAutomock : unit -> unit = "jest.enableAutomock"

  (* genMockFromModule *)
  external resetModules : unit -> unit = "jest.resetModules"

  external inferred_fn :
    unit -> (('a -> 'b Js.undefined[@u]), 'a, 'b Js.undefined) MockJs.fn
    = "jest.fn" (* not sure how useful this really is *)

  external fn : ('a -> 'b) -> ('a -> 'b, 'a, 'b) MockJs.fn = "jest.fn"

  external fn2 :
    (('a -> 'b -> 'c)[@u]) -> (('a -> 'b -> 'c[@u]), 'a * 'b, 'c) MockJs.fn
    = "jest.fn"

  (* TODO
  external fn3 : ('a -> 'b -> 'c -> 'd) -> ('a * 'b * 'c) MockJs.fn = "jest.fn"
  external fn4 : ('a -> 'b -> 'c -> 'd -> 'e) -> ('a * 'b * 'c * 'd) MockJs.fn = "jest.fn"
  external fn5 : ('a -> 'b -> 'c -> 'd -> 'e -> 'f) -> ('a * 'a * 'c * 'd * 'e) MockJs.fn = "jest.fn"
  external fn6 : ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g) -> ('a * 'b * 'c * 'd * 'e * 'f) MockJs.fn = "jest.fn"
  *)
  (* external isMockFunction : MockJs.fn -> Js.boolean = "jest.isMockFunction" *)
  (* pointless with types? *)
  external mock : string -> unit = "jest.mock"
  external mockWithFactory : string -> (unit -> 'a) -> unit = "jest.mock"

  external mockVirtual : string -> (unit -> 'a) -> < .. > Js.t -> unit
    = "jest.mock"

  (* TODO If this is merely defined, babel-plugin-jest-hoist fails with "The second argument of `jest.mock` must be a function." Silly thing.
  let mockVirtual : string -> (unit -> 'a) -> unit =
    fun moduleName factory -> mockVirtual moduleName factory [%mel.obj { _virtual = Js.true_ }]
  *)
  external clearAllMocks : unit -> unit = "jest.clearAllMocks"
  external resetAllMocks : unit -> unit = "jest.resetAllMocks"
  external setMock : string -> < .. > Js.t -> unit = "jest.setMock"
  external unmock : string -> unit = "jest.unmock"

  external spyOn :
    (< .. > Js.t as 'this) -> string -> (unit, unit, 'this) MockJs.fn
    = "jest.spyOn" (* this is a bit too dynamic *)
end
