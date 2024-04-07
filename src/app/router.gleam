import wisp.{type Request, type Response}
import gleam/dynamic.{type Dynamic}
import gleam/string_builder
import gleam/http.{Get, Post}
import gleam/string
import app/web
import gleam/result
import gleam/json

pub type Question {
  Question(prompt: String, answer: String)
}

fn decode_question(json: Dynamic) -> Result(Question, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      Question,
      dynamic.field("prompt", dynamic.string),
      dynamic.field("answer", dynamic.string),
    )
  decoder(json)
}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req) 

  case wisp.path_segments(req){
    [] -> index(req)
    ["questions"] -> handle_questions(req)
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

pub fn handle_questions(req: Request) -> Response {
  use req <- web.middleware(req)
  use <- wisp.require_method(req, Post)

  // This middleware parses a `Dynamic` value from the request body.
  // It returns an error response if the body is not valid JSON, or
  // if the content-type is not `application/json`, or if the body
  // is too large.
  use json <- wisp.require_json(req)

  let result = {
    // The dynamic value can be decoded into a `Question` value.
    use question <- result.try(decode_question(json))

    // And then a JSON response can be created from the question.
    let object =
      json.object([
        #("prompt", json.string(question.prompt)),
        #("answer", json.string(question.answer)),
        #("saved", json.bool(True)),
        #("name", json.string(generate_name(question.answer))),
      ])
    Ok(json.to_string_builder(object))
  }

  // An appropriate response is returned depending on whether the JSON could be
  // successfully handled or not.
  case result {
    Ok(json) -> wisp.json_response(json, 201)


    // In a real application we would probably want to return some JSON error
    // object, but for this example we'll just return an empty response.
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn generate_name(n: String) -> String{
  case n {
    "Yogurt" -> "Wuhter"
    "Hotdogs" -> "Walnut"
    "Spam" -> "Wishnut"
    _ -> "Blue"
  }
}
