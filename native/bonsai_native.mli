open! Core

module Effect = Bonsai.Effect

type edge_insets =
  { top : float
  ; start : float
  ; bottom : float
  ; end_ : float
  }
[@@deriving sexp_of]

type frame =
  { width : float option
  ; height : float option
  }
[@@deriving sexp_of]

type node

val text : string -> node
val button : string -> on_click:unit Effect.t -> node
val text_field
  :  ?placeholder:string
  -> text:string
  -> on_change:(string -> unit Effect.t)
  -> unit
  -> node

val vstack : ?spacing:float -> node list -> node
val hstack : ?spacing:float -> node list -> node
val scroll_view : node -> node
val list : 'a list -> key:('a -> string) -> row:('a -> node) -> node
val padding : ?insets:edge_insets -> node -> node
val frame : ?width:float -> ?height:float -> node -> node

module Bridge : sig
  type t

  val render : schedule_event:(unit Effect.t -> unit) -> node -> t
  val json : t -> string
  val dispatch_click : t -> int -> unit
  val dispatch_change : t -> int -> text:string -> unit
end

module App : sig
  type t

  val create
    :  ?optimize:bool
    -> time_source:Bonsai.Time_source.t
    -> (Bonsai.graph -> node Bonsai.t)
    -> t

  val render_json : t -> string
  val dispatch_click : t -> int -> unit
  val dispatch_change : t -> int -> text:string -> unit
end
