type assertion

module type Asserter = sig
  type 'a t
  val affirm : 'a t -> unit
end

module Runner (A : Asserter) : sig
  val test : string -> (unit -> _ A.t) -> unit
  val testAsync : string -> ?timeout:int -> ((_ A.t -> unit) -> unit) -> unit
  val testPromise : string -> ?timeout:int -> (unit -> _ A.t Js.Promise.t) -> unit
  val testAll : string -> 'a list -> ('a -> _ A.t) -> unit

  val describe : string -> (unit -> unit) -> unit

  external beforeAll : (unit -> unit [@mel.uncurry]) -> unit = "beforeAll"
  val beforeAllAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
  val beforeAllPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
  external beforeEach : (unit -> unit [@mel.uncurry]) -> unit = "beforeEach"
  val beforeEachAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
  val beforeEachPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
  external afterAll : (unit -> unit [@mel.uncurry]) -> unit = "afterAll"
  val afterAllAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
  val afterAllPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
  external afterEach : (unit -> unit [@mel.uncurry]) -> unit = "afterEach"
  val afterEachAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
  val afterEachPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit

  module Only : sig
    val test : string -> (unit -> _ A.t) -> unit
    val testAsync : string -> ?timeout:int -> ((_ A.t -> unit) -> unit) -> unit
    val testPromise : string -> ?timeout:int -> (unit -> _ A.t Js.Promise.t) -> unit
    val testAll : string -> 'a list -> ('a -> _ A.t) -> unit
    val describe : string -> (unit -> unit) -> unit
  end

  module Skip : sig
    val test : string -> (unit -> _ A.t) -> unit
    val testAsync : string -> ?timeout:int -> ((_ A.t -> unit) -> unit) -> unit
    val testPromise : string -> ?timeout:int -> (unit -> _ A.t Js.Promise.t) -> unit
    val testAll : string -> 'a list -> ('a -> _ A.t) -> unit
    val describe : string -> (unit -> unit) -> unit
  end
end

val test : string -> (unit -> assertion) -> unit
val testAsync : string -> ?timeout:int -> ((assertion -> unit) -> unit) -> unit
val testPromise : string -> ?timeout:int -> (unit -> assertion Js.Promise.t) -> unit
val testAll : string -> 'a list -> ('a -> assertion) -> unit

val describe : string -> (unit -> unit) -> unit

external beforeAll : (unit -> unit [@mel.uncurry]) -> unit = "beforeAll"
val beforeAllAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
val beforeAllPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
external beforeEach : (unit -> unit [@mel.uncurry]) -> unit = "beforeEach"
val beforeEachAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
val beforeEachPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
external afterAll : (unit -> unit [@mel.uncurry]) -> unit = "afterAll"
val afterAllAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
val afterAllPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit
external afterEach : (unit -> unit [@mel.uncurry]) -> unit = "afterEach"
val afterEachAsync : ?timeout:int -> ((unit -> unit) -> unit) -> unit
val afterEachPromise : ?timeout:int -> (unit -> 'a Js.Promise.t) -> unit

module Only : sig
  val test : string -> (unit -> assertion) -> unit
  val testAsync : string -> ?timeout:int -> ((assertion -> unit) -> unit) -> unit
  val testPromise : string -> ?timeout:int -> (unit -> assertion Js.Promise.t) -> unit
  val testAll : string -> 'a list -> ('a -> assertion) -> unit
  val describe : string -> (unit -> unit) -> unit
end

module Skip : sig
  val test : string -> (unit -> assertion) -> unit
  val testAsync : string -> ?timeout:int -> ((assertion -> unit) -> unit) -> unit
  val testPromise : string -> ?timeout:int -> (unit -> assertion Js.Promise.t) -> unit
  val testAll : string -> 'a list -> ('a -> assertion) -> unit
  val describe : string -> (unit -> unit) -> unit
end

module Todo : sig
  val test : string -> unit
end

val pass : assertion
val fail : string -> assertion

module Expect : sig
  type 'a plainPartial = [`Just of 'a]
  type 'a invertedPartial = [`Not of 'a]
  type 'a partial = [
    | 'a plainPartial
    | 'a invertedPartial
  ]

  val expect : 'a -> 'a plainPartial
  val expectFn : ('a -> 'b) -> 'a -> (unit -> 'b) plainPartial (* EXPERIMENTAL *)

  val toBe : 'a -> [< 'a partial] -> assertion
  val toBeCloseTo : float -> [< float partial] -> assertion
  val toBeSoCloseTo : float -> digits:int -> [< float partial] -> assertion
  val toBeGreaterThan : 'a -> [< 'a partial] -> assertion
  val toBeGreaterThanOrEqual : 'a -> [< 'a partial] -> assertion
  val toBeLessThan : 'a -> [< 'a partial] -> assertion
  val toBeLessThanOrEqual : 'a -> [< 'a partial] -> assertion
  val toBeSupersetOf : 'a array -> [< 'a array partial] -> assertion
  val toContain : 'a -> [< 'a array partial] -> assertion
  val toContainEqual : 'a -> [< 'a array partial] -> assertion
  val toContainString : string -> [< string partial] -> assertion
  val toEqual : 'a -> [< 'a partial] -> assertion
  val toHaveLength : int -> [< 'a array partial] -> assertion
  val toMatch : string -> [< string partial] -> assertion
  val toMatchInlineSnapshot : string -> _ plainPartial -> assertion
  val toMatchRe : Js.Re.t -> [< string partial] -> assertion
  val toMatchSnapshot : _ plainPartial -> assertion
  val toMatchSnapshotWithName : string -> _ plainPartial -> assertion
  val toThrow : [< (unit -> _) partial] -> assertion
  val toThrowErrorMatchingSnapshot : (unit -> _) plainPartial -> assertion

  val not_ : 'a plainPartial -> 'a invertedPartial
  val not__ : 'a plainPartial -> 'a invertedPartial

  module Operators : sig
    (** experimental *)

    val (==) : [< 'a partial] -> 'a -> assertion
    val (>)  : [< 'a partial] -> 'a -> assertion
    val (>=) : [< 'a partial] -> 'a -> assertion
    val (<)  : [< 'a partial] -> 'a -> assertion
    val (<=) : [< 'a partial] -> 'a -> assertion
    val (=)  : [< 'a partial] -> 'a -> assertion
    val (<>) : 'a plainPartial -> 'a -> assertion
    val (!=) : 'a plainPartial -> 'a -> assertion
  end
end

module ExpectJs : sig
  include module type of Expect

  val toBeDefined : [< _ Js.undefined partial] -> assertion
  val toBeFalsy : [< _ partial] -> assertion
  val toBeNull : [< _ Js.null partial] -> assertion
  val toBeTruthy : [< _ partial] -> assertion
  val toBeUndefined : [< _ Js.undefined partial] -> assertion
  val toContainProperties : string array -> [< < .. > Js.t partial] -> assertion
  val toMatchObject : < .. > Js.t -> [< < .. > Js.t partial] -> assertion
end

module MockJs : sig
  (** experimental *)

  type ('fn, 'args, 'ret) fn

  val new0 : (unit -> 'ret, unit, 'ret) fn -> 'ret
  val new1 : 'a -> ('a -> 'ret, 'a, 'ret) fn -> 'ret
  val new2 : 'a -> 'b -> (('a -> 'b -> 'ret) [@u], 'a * 'b, 'ret) fn -> 'ret

  external fn : ('fn, _, _) fn -> 'fn = "%identity"
  val calls : (_, 'args, _) fn -> 'args array
  val instances : (_, _, 'ret) fn -> 'ret array

  (** Beware: this actually replaces `mock`, not just `mock.instances` and `mock.calls` *)
  external mockClear : unit = "mockClear" [@@mel.send.pipe: _ fn]
  external mockReset : unit = "mockReset" [@@mel.send.pipe: _ fn]
  external mockImplementation : 'fn -> 'self = "mockImplementation" [@@mel.send.pipe: ('fn, _, _) fn as 'self]
  external mockImplementationOnce : 'fn -> 'self = "mockImplementationOnce" [@@mel.send.pipe: ('fn, _, _) fn as 'self]
  external mockReturnThis : unit = "mockReturnThis" [@@mel.send.pipe: (_, _, 'ret) fn] (* not type safe, we don't know what `this` actually is *)
  external mockReturnValue : 'ret -> 'self = "mockReturnValue" [@@mel.send.pipe: (_, _, 'ret) fn as 'self]
  external mockReturnValueOnce : 'ret -> 'self = "mockReturnValueOnce" [@@mel.send.pipe: (_, _, 'ret) fn as 'self]
end

module Jest : sig
  type globals

  external globals : globals = "@jest/globals" [@@mel.module]

  type t

  external jest : globals -> t = "jest" [@@mel.get]

  external clearAllTimers : unit -> unit = "clearAllTimers" [@@mel.send.pipe: t] 
  external runAllTicks : unit -> unit = "runAllTicks" [@@mel.send.pipe: t] 
  external runAllTimers : unit -> unit = "runAllTimers" [@@mel.send.pipe: t] 
  external runAllImmediates : unit -> unit = "runAllImmediates" [@@mel.send.pipe: t] 
  external advanceTimersByTime : int -> unit = "advanceTimersByTime" [@@mel.send.pipe: t] 
  external runOnlyPendingTimers : unit -> unit = "runOnlyPendingTimers" [@@mel.send.pipe: t] 
  type fakeTimersConfig = {
    legacyFakeTimers: bool
  }
  external useFakeTimers : ?config:fakeTimersConfig -> unit -> unit = "useFakeTimers" [@@mel.send.pipe: t] 
  external useRealTimers : unit -> unit = "useRealTimers" [@@mel.send.pipe: t] 
end

module JestJs : sig
  (** experimental *)

  external disableAutomock : unit -> unit = "disableAutomock"  [@@mel.send.pipe: Jest.t] 
  external enableAutomock : unit -> unit = "enableAutomock"  [@@mel.send.pipe: Jest.t] 
  external resetModules : unit -> unit = "resetModules"  [@@mel.send.pipe: Jest.t] 
  external inferred_fn : unit -> ('a -> 'b Js.undefined [@u], 'a, 'b Js.undefined) MockJs.fn = "fn"  [@@mel.send.pipe: Jest.t] 
  external fn : ('a -> 'b) -> ('a -> 'b, 'a, 'b) MockJs.fn = "fn"  [@@mel.send.pipe: Jest.t] 
  external fn2 : ('a -> 'b -> 'c [@u]) -> (('a -> 'b -> 'c [@u]), 'a * 'b, 'c) MockJs.fn = "fn"  [@@mel.send.pipe: Jest.t] 
  external mock : string -> unit = "mock"  [@@mel.send.pipe: Jest.t] 
  external mockWithFactory : string -> (unit -> 'a) ->unit = "mock"  [@@mel.send.pipe: Jest.t] 
  external mockVirtual : string -> (unit -> 'a) -> < .. > Js.t -> unit = "mock"  [@@mel.send.pipe: Jest.t] 
  external clearAllMocks : unit -> unit = "clearAllMocks"  [@@mel.send.pipe: Jest.t] 
  external resetAllMocks : unit -> unit = "resetAllMocks"  [@@mel.send.pipe: Jest.t] 
  external setMock : string -> < .. > Js.t -> unit = "setMock"  [@@mel.send.pipe: Jest.t] 
  external unmock : string -> unit = "unmock"  [@@mel.send.pipe: Jest.t] 
  external spyOn : (< .. > Js.t as 'this) -> string -> (unit, unit, 'this) MockJs.fn = "spyOn"  [@@mel.send.pipe: Jest.t] 
end
