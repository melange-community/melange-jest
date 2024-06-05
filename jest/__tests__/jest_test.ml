open Jest
open Expect
open! Expect.Operators

external setTimeout : (unit -> unit) -> int -> unit = "setTimeout"
type timers
external timers : timers = "timers" [@@mel.module]
external setImmediate : (unit -> unit) -> unit = "setImmediate" [@@mel.send.pipe: timers]
external nextTick : (unit -> unit) -> unit = "process.nextTick"

let () = 

describe "Fake Timers" (fun () ->
  test "runAllTimers" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    setTimeout (fun () -> flag := true) 0;
    let before = !flag in
    Jest.runAllTimers () Jest.(jest globals);
    
    expect (before, !flag) = (false, true)
  );
  
  test "runAllTicks" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    nextTick (fun () -> flag := true);
    let before = !flag in
    Jest.runAllTicks () Jest.(jest globals);
    
    expect (before, !flag) = (false, true)
  );
  
  (* todo: fixme
  test "runAllImmediates" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    setImmediate (fun () -> flag := true) timers;
    let before = !flag in
    Jest.runAllImmediates () Jest.(jest globals);
    
    expect (before, !flag) = (false, true)
  ); 
  
  test "runTimersToTime" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    setTimeout (fun () -> flag := true) 1500;
    let before = !flag in
    Jest.runTimersToTime 1000 Jest.(jest globals);
    let inbetween = !flag in
    Jest.runTimersToTime 1000 Jest.(jest globals);
    
    expect (before, inbetween, !flag) = (false, false, true)
  ); *)

  test "advanceTimersByTime" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    setTimeout(fun () -> flag := true) 1500;
    let before = !flag in
    Jest.advanceTimersByTime 1000 Jest.(jest globals);
    let inbetween = !flag in
    Jest.advanceTimersByTime 1000 Jest.(jest globals);
    
    expect (before, inbetween, !flag) = (false, false, true)
  );
  
  test "runOnlyPendingTimers" (fun () ->
    let count = ref 0 in
    Jest.useFakeTimers () Jest.(jest globals);
    let rec recursiveTimeout () = count := !count + 1; setTimeout recursiveTimeout 1500 in
    recursiveTimeout ();
    let before = !count in
    Jest.runOnlyPendingTimers () Jest.(jest globals);
    let inbetween = !count in
    Jest.runOnlyPendingTimers () Jest.(jest globals);
    
    expect (before, inbetween, !count) = (1, 2, 3)
  );
  
  test "clearAllTimers" (fun () ->
    let flag = ref false in
    Jest.useFakeTimers () Jest.(jest globals);
    setImmediate (fun () -> flag := true) timers;
    let before = !flag in
    Jest.clearAllTimers () Jest.(jest globals);
    Jest.runAllTimers () Jest.(jest globals);
    
    expect (before, !flag) = (false, false)
  );
  
  testAsync "clearAllTimers" (fun finish ->
    Jest.useFakeTimers () Jest.(jest globals);
    Jest.useRealTimers () Jest.(jest globals);
    setImmediate (fun () -> finish pass) timers;
  );
);
