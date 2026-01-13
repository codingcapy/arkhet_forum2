import gleam/dynamic/decode
import gleam/json
import rsvp

pub type User {
  User(
    user_id: String,
    username: String,
    email: String,
    password: String,
    profile_pic: String,
    role: String,
    status: String,
    preference: String,
    created_at: String,
  )
}

pub type AuthResult {
  AuthResult(user: User, token: String)
}

pub type Post {
  Post(
    post_id: Int,
    user_id: String,
    community_id: String,
    title: String,
    content: String,
    status: String,
    created_at: String,
  )
}

fn user_decoder() -> decode.Decoder(User) {
  use user_id <- decode.field("userId", decode.string)
  use username <- decode.field("username", decode.string)
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  use profile_pic <- decode.field("profilePic", decode.string)
  use role <- decode.field("role", decode.string)
  use status <- decode.field("status", decode.string)
  use preference <- decode.field("preference", decode.string)
  use created_at <- decode.field("createdAt", decode.string)
  decode.success(User(
    user_id:,
    username:,
    email:,
    password:,
    profile_pic:,
    role:,
    status:,
    preference:,
    created_at:,
  ))
}

fn post_decoder() {
  use post_id <- decode.field("postId", decode.int)
  use user_id <- decode.field("userId", decode.string)
  use community_id <- decode.field("communityId", decode.string)
  use title <- decode.field("title", decode.string)
  use content <- decode.field("content", decode.string)
  use status <- decode.field("status", decode.string)
  use created_at <- decode.field("createdAt", decode.string)
  decode.success(Post(
    post_id:,
    user_id:,
    community_id:,
    title:,
    content:,
    status:,
    created_at:,
  ))
}

fn login_response_decoder() -> decode.Decoder(AuthResult) {
  use user <- decode.field("user", user_decoder())
  use token <- decode.field("token", decode.string)
  decode.success(AuthResult(user:, token:))
}

fn base_url() -> String {
  "http://localhost:3333/api/v0"
}

pub fn post_signup(
  msg_wrapper wrapper,
  username username,
  email email,
  password password,
) {
  let handler = {
    rsvp.expect_json(decode.at(["user"], user_decoder()), wrapper)
  }
  rsvp.post(
    echo base_url() <> "/users",
    json.object([
      #("username", json.string(username)),
      #("email", json.string(email)),
      #("password", json.string(password)),
    ]),
    handler,
  )
}

pub fn post_login(msg_wrapper wrapper, email email, password password) {
  let handler =
    rsvp.expect_json(decode.at(["result"], login_response_decoder()), wrapper)
  rsvp.post(
    echo base_url() <> "/user/login",
    json.object([
      #("email", json.string(email)),
      #("password", json.string(password)),
    ]),
    handler,
  )
}

pub fn validate_jwt(msg_wrapper wrapper, token token) {
  let handler = rsvp.expect_json(decode.at(["result"], user_decoder()), wrapper)
  rsvp.post(echo base_url() <> "/user/validation", json.null(), handler)
}

pub fn post_create_post(
  msg_wrapper wrapper,
  user_id user_id,
  community_id community_id,
  title title,
  content content,
) {
  let handler = {
    rsvp.expect_json(decode.at(["newPost"], post_decoder()), wrapper)
  }
  rsvp.post(
    echo base_url() <> "/posts",
    json.object([
      #("userId", json.string(user_id)),
      #("communityId", json.string(community_id)),
      #("title", json.string(title)),
      #("content", json.string(content)),
    ]),
    handler,
  )
}

pub fn get_posts(msg_wrapper wrapper) {
  let handler = {
    rsvp.expect_json(decode.list(post_decoder()), wrapper)
  }
  rsvp.get(base_url() <> "/posts", handler)
}

pub fn get_bugreport_posts(msg_wrapper wrapper) {
  let handler = {
    rsvp.expect_json(decode.list(post_decoder()), wrapper)
  }
  rsvp.get(base_url() <> "/posts/bugreports", handler)
}

pub fn get_techsupport_posts(msg_wrapper wrapper) {
  let handler = {
    rsvp.expect_json(decode.list(post_decoder()), wrapper)
  }
  rsvp.get(base_url() <> "/posts/techsupport", handler)
}

pub fn get_general_posts(msg_wrapper wrapper) {
  let handler = {
    rsvp.expect_json(decode.list(post_decoder()), wrapper)
  }
  rsvp.get(base_url() <> "/posts/general", handler)
}
