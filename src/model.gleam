import api
import gleam/option
import gleam/result
import gleam/uri
import modem

pub type Model {
  Model(
    route: Route,
    signup_ui: SignupUi,
    login_ui: LoginUi,
    auth_token: option.Option(String),
    current_user: option.Option(api.User),
    create_post_ui: CreatePostUi,
    show_create_post: Bool,
  )
}

pub type Route {
  Home
  Login
  Signup
  BugReports
  GeneralDiscussions
  TechnicalSupport
}

pub fn initial_route() -> Route {
  modem.initial_uri()
  |> result.map(fn(uri: uri.Uri) {
    uri.path
    |> uri.path_segments
    |> route_from_path
  })
  |> result.unwrap(Home)
}

pub fn route_from_path(path: List(String)) -> Route {
  case path {
    [] -> Home
    ["login"] -> Login
    ["signup"] -> Signup
    ["bugreports"] -> BugReports
    ["generaldiscussions"] -> GeneralDiscussions
    ["technicalsupport"] -> TechnicalSupport
    _ -> Home
  }
}

pub type SignupUi {
  SignupUi(
    username: String,
    email: String,
    password: String,
    error: option.Option(String),
  )
}

pub fn initial_signup_ui() -> SignupUi {
  SignupUi(username: "", email: "", password: "", error: option.None)
}

pub type LoginUi {
  LoginUi(email: String, password: String, error: option.Option(String))
}

pub fn initial_login_ui() -> LoginUi {
  LoginUi(email: "", password: "", error: option.None)
}

pub type CreatePostUi {
  CreatePostUi(title: String, content: String, community_id: String)
}

pub fn initial_create_post_ui() -> CreatePostUi {
  CreatePostUi(title: "", content: "", community_id: "general")
}

pub type Community {
  General
  BugReport
  TechSupport
}

pub fn community_to_id(community: Community) -> String {
  case community {
    General -> "general"
    BugReport -> "bugreport"
    TechSupport -> "techsupport"
  }
}
