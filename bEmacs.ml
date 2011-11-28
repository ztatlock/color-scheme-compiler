(* TODO:
   - Neutral faces get translated (variable -> font-lock-variable-name-face)
   - Emacs-understandable names get whitelisted (org-level-1 ok,
     pat-vim-highlihgt not ok)
*)

module M  = Map
module CS = ColorScheme
module SM = CS.StringMap
module F  = Format

(* pmr: factor this out *)
let (|>) x f = f x

(* pmr: factor this out *)
let find_local_name name_map name =
  try List.assoc name name_map with Not_found -> name

(* pmr: factor this out *)
let print_map key_map pr ppf m =
  SM.iter begin fun k v ->
    pr ppf (find_local_name key_map k) v
  end m

(******************************************************************************)
(********************** Color scheme names to Emacs names *********************)
(******************************************************************************)

let face_map =
  [ ("selection",    "region")
  ; ("keyword",      "font-lock-keyword-face")
  ; ("comment",      "font-lock-comment-face")
  ; ("builtin",      "font-lock-builtin-face")
  ; ("variable",     "font-lock-variable-name-face")
  ; ("function",     "font-lock-function-name-face")
  ; ("type",         "font-lock-type-face")
  ; ("string",       "font-lock-string-face")
  ; ("preprocessor", "font-lock-preprocessor-face")
  ; ("warning",      "font-lock-warning-face")
  ]

let attribute_map =
  [ ("color",       "foreground")
  ; ("font-weight", "weight")
  ]

let unquoted_attributes =
  [ "weight"
  ]

let body_face_attribute_map =
  [ ("color",      "foreground-color")
  ; ("background", "background-color")
  ]

(******************************************************************************)
(**************************** Color scheme printers ***************************)
(******************************************************************************)

let print_attribute attr ppf = function
  | CS.Color (r, g, b) -> F.fprintf ppf "\"#%02x%02x%02x\"" r g b (* pmr: factor out hex color printing *)
  | CS.String s        ->
    if List.mem attr unquoted_attributes then
      F.fprintf ppf "%s" s
    else F.fprintf ppf "\"%s\"" s

let print_face_attributes =
  print_map
    attribute_map
    (fun ppf k v -> F.fprintf ppf ":%s %a@;" k (print_attribute k) v)

let print_faces =
  print_map
    face_map
    begin fun ppf k v ->
      F.fprintf ppf "(%s ((t (@[%a@]))))@\n" k print_face_attributes v
    end

let print_body_face_option ppf = function
  | None      -> ()
  | Some face ->
    SM.iter begin fun attr v ->
      F.fprintf ppf "(%s . %a)@\n"
        (find_local_name body_face_attribute_map attr)
        (print_attribute attr) v
    end face

let print ppf {CS.name = name; CS.faces = faces} =
  let body_opt, faces = CS.extract_face faces "body" in
    F.fprintf ppf "(defun color-theme-%s ()@." name;
    F.fprintf ppf "  (interactive)@.";
    F.fprintf ppf "  (color-theme-install@.";
    F.fprintf ppf "    `(color-theme-%s@." name;
    F.fprintf ppf "      (@[%a@])@." print_body_face_option body_opt;
    F.fprintf ppf "      @[%a@]@." print_faces faces;
    F.fprintf ppf "  )))@.";
    F.fprintf ppf "(provide 'color-theme-%s)@." name

let out_name f =
  "TODO-emacs-out_name"

