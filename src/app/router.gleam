import wisp.{type Request, type Response}
import gleam/string_builder
import gleam/http.{Get, Post}
import gleam/string
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
  //generate a name + w at the front 
  //TODO need to take in context/input from front end and convert to string and pass it in here
  let test_str = "Michael" 
  //maybe but do not use string builder or find way to convert string builder to string
  //let context_str = string_builder.from_string(test_str)
  let generated_name = string.drop_left(from: test_str, up_to: 1) 
  let return_name = string.concat(["W", generated_name])

  let html = string_builder.from_string(return_name)
  wisp.ok()
  |> wisp.html_body(html)
}
