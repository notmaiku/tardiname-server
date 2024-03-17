import wisp.{type Request, type Response}
import gleam/string_builder
import gleam/http.{Get, Post}
import gleam/string
import app/web
import gleam/result
import gleam/list


pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req) 

  case wisp.path_segments(req){
    [] -> index(req)
    ["purple"] -> handle_form_submission(req)
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

pub fn handle_form_submission(req: Request) -> Response {
  // This middleware parses a `wisp.FormData` from the request body.
  // It returns an error response if the body is not valid form data, or
  // if the content-type is not `application/x-www-form-urlencoded` or
  // `multipart/form-data`, or if the body is too large.
  use formdata <- wisp.require_form(req)

  // The list and result module are used here to extract the values from the
  // form data.
  // Alternatively you could also pattern match on the list of values (they are
  // sorted into alphabetical order), or use a HTML form library.
  let result = {
    use name <- result.try(list.key_find(formdata.values, "name"))

    let curr_name = wisp.escape_html(name) 
    let generated_name = string.drop_left(from: curr_name, up_to: 1) 
    let return_name = string.concat(["W", generated_name])

   // let html = string_builder.from_string(return_name)
    let greeting =
      "Hi,  " <> wisp.escape_html(return_name) <> "!"
    Ok(greeting)
  }

  // An appropriate response is returned depending on whether the form data
  // could be successfully handled or not.
  case result {
    Ok(content) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(content))
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}