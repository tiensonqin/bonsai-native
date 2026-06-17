open! Core

let app =
  lazy
    (Bonsai_android.App.create
       ~time_source:(Bonsai.Time_source.create ~start:Time_ns.epoch)
       Counter_component.component)
;;

let render () = Bonsai_android.App.render_json (Lazy.force app)
let dispatch_click event_id = Bonsai_android.App.dispatch_click (Lazy.force app) event_id

let dispatch_change event_id text =
  Bonsai_android.App.dispatch_change (Lazy.force app) event_id ~text
;;

let () =
  Callback.register "bonsai_android_render" render;
  Callback.register "bonsai_android_dispatch_click" dispatch_click;
  Callback.register "bonsai_android_dispatch_change" dispatch_change
;;
