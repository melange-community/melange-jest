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
  external clearAllTimers : unit -> unit = "jest.clearAllTimers"
  external runAllTicks : unit -> unit = "jest.runAllTicks"
  external runAllTimers : unit -> unit = "jest.runAllTimers"
  external runAllImmediates : unit -> unit = "jest.runAllImmediates"
  external runTimersToTime : int -> unit = "jest.runTimersToTime"
  external advanceTimersByTime : int -> unit = "jest.advanceTimersByTime"
  external runOnlyPendingTimers : unit -> unit = "jest.runOnlyPendingTimers"
  external useFakeTimers : unit -> unit = "jest.useFakeTimers"
  external useRealTimers : unit -> unit = "jest.useRealTimers"
end

module JestJs : sig
  (** experimental *)

  external disableAutomock : unit -> unit = "jest.disableAutomock"
  external enableAutomock : unit -> unit = "jest.enableAutomock"
  external resetModules : unit -> unit = "jest.resetModules"
  external inferred_fn : unit -> ('a -> 'b Js.undefined [@u], 'a, 'b Js.undefined) MockJs.fn = "jest.fn"
  external fn : ('a -> 'b) -> ('a -> 'b, 'a, 'b) MockJs.fn = "jest.fn"
  external fn2 : ('a -> 'b -> 'c [@u]) -> (('a -> 'b -> 'c [@u]), 'a * 'b, 'c) MockJs.fn = "jest.fn"
  external mock : string -> unit = "jest.mock"
  external mockWithFactory : string -> (unit -> 'a) ->unit = "jest.mock"
  external mockVirtual : string -> (unit -> 'a) -> < .. > Js.t -> unit = "jest.mock"
  external clearAllMocks : unit -> unit = "jest.clearAllMocks"
  external resetAllMocks : unit -> unit = "jest.resetAllMocks"
  external setMock : string -> < .. > Js.t -> unit = "jest.setMock"
  external unmock : string -> unit = "jest.unmock"
  external spyOn : (< .. > Js.t as 'this) -> string -> (unit, unit, 'this) MockJs.fn = "jest.spyOn"
end
