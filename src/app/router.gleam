import wisp.{type Request, type Response}
import gleam/string_builder
import gleam/http.{Get, Post}
import app/web

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req) 

  case wisp.path_segments(req){
    [] -> index(req)
    _ -> wisp.not_found()
    }

  }
  fn index(req: Request) -> Response {
   use <- wisp.require_method(req, Get) 

  let html = string_builder.from_string("Wuhter")
  wisp.ok()
  |> wisp.html_body(html)
}
