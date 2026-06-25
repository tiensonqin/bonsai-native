open! Core

module Driver = Bonsai_native.App_driver

type view =
  { mutable text : string
  ; mutable click : unit -> unit
  }

let time_source () = Bonsai.Time_source.create ~start:Time_ns.epoch

let counter_component graph =
  let open Bonsai.Let_syntax in
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Int.to_string count, set_count (count + 1)
;;

let create_counter_app () =
  Driver.create
    ~time_source:(time_source ())
    counter_component
    ~render:(fun ~schedule_event (text, effect) ->
      { text; click = (fun () -> schedule_event effect) })
    ~update:(fun view ~schedule_event (text, effect) ->
      view.text <- text;
      view.click <- (fun () -> schedule_event effect);
      view)
;;

let rendered_exn app = Driver.rendered app |> Option.value_exn

let%test_unit "schedule-only events update on the next explicit render" =
  let app = create_counter_app () in
  Driver.flush app;
  let view = rendered_exn app in
  [%test_result: string] view.text ~expect:"0";
  view.click ();
  [%test_result: string] view.text ~expect:"0";
  Driver.flush app;
  [%test_result: string] view.text ~expect:"1"
;;

let%test_unit "schedule-and-render events update the mounted view immediately" =
  let app = create_counter_app () in
  Driver.flush_and_render app;
  let view = rendered_exn app in
  [%test_result: string] view.text ~expect:"0";
  view.click ();
  [%test_result: string] view.text ~expect:"1";
  view.click ();
  [%test_result: string] view.text ~expect:"2"
;;

let%test_unit "asynchronous effects rerender when their callback completes" =
  let complete = ref None in
  let component graph =
    let open Bonsai.Let_syntax in
    let count, set_count = Bonsai.state 0 graph in
    let%arr count and set_count in
    let effect =
      Bonsai.Effect.bind
        (Bonsai.Effect.Expert.of_fun ~f:(fun ~callback ~on_exn:_ ->
           complete := Some (fun () -> callback ())))
        ~f:(fun () -> set_count (count + 1))
    in
    Int.to_string count, effect
  in
  let app =
    Driver.create
      ~time_source:(time_source ())
      component
      ~render:(fun ~schedule_event (text, effect) ->
        { text; click = (fun () -> schedule_event effect) })
      ~update:(fun view ~schedule_event (text, effect) ->
        view.text <- text;
        view.click <- (fun () -> schedule_event effect);
        view)
  in
  Driver.flush_and_render app;
  let view = rendered_exn app in
  view.click ();
  [%test_result: string] view.text ~expect:"0";
  (Option.value_exn !complete) ();
  [%test_result: string] view.text ~expect:"1"
;;
