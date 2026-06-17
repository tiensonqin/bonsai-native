open! Core

module Android = Bonsai_android

let component graph =
  let open Bonsai.Let_syntax in
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Android.vstack
    ~spacing:12.
    [ Android.text ("Count: " ^ Int.to_string count)
    ; Android.button "Increment" ~on_click:(set_count (count + 1))
    ]
  |> Android.padding
;;
