open! Core

let () =
  let app =
    Bonsai_android.App.create
      ~time_source:(Bonsai.Time_source.create ~start:Time_ns.epoch)
      Counter_component.component
  in
  print_endline (Bonsai_android.App.render_json app)
;;
