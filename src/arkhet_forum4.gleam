import api
import bugreports
import gleam/io
import gleam/option
import gleam/string
import gleam/uri
import home
import login
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element/html
import lustre/event
import message
import model.{type Model, type Route, BugReports, Home, Login, Model, Signup}
import modem
import signup

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_) {
  let model =
    model.Model(
      route: model.initial_route(),
      signup_ui: model.initial_signup_ui(),
      login_ui: model.initial_login_ui(),
      auth_token: option.None,
      current_user: option.None,
      create_post_ui: model.initial_create_post_ui(),
      show_create_post: False,
    )
  let fx = effect.batch([modem.init(on_url_change)])
  #(model, fx)
}

fn update(
  model: Model,
  msg: message.Msg,
) -> #(Model, effect.Effect(message.Msg)) {
  case echo msg {
    message.OnRouteChange(route) -> #(
      model.Model(..model, route: route),
      effect.none(),
    )
    message.Navigate(path) -> #(
      model,
      modem.push(path, option.None, option.None),
    )
    message.UserChangedSignupUsername(username) -> {
      let signup_ui = model.SignupUi(..model.signup_ui, username: username)
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserChangedSignupEmail(email) -> {
      let signup_ui =
        model.SignupUi(..model.signup_ui, email: email, error: option.None)
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserChangedSignupPassword(password) -> {
      let signup_ui =
        model.SignupUi(
          ..model.signup_ui,
          password: password,
          error: option.None,
        )
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserSubmittedSignup -> {
      let username = echo model.signup_ui.username |> string.trim()
      let email = echo model.signup_ui.email |> string.trim()
      let password = echo model.signup_ui.password |> string.trim()
      let fx =
        api.post_signup(message.ApiCreatedUser, username:, email:, password:)
      #(model, fx)
    }
    message.ApiCreatedUser(Ok(_)) -> {
      let email = echo model.signup_ui.email |> string.trim()
      let password = echo model.signup_ui.password |> string.trim()
      #(
        Model(..model),
        effect.batch([
          api.post_login(message.ApiLoggedInUser, email:, password:),
        ]),
      )
    }
    message.ApiCreatedUser(Error(error)) -> {
      let signup_ui =
        model.SignupUi(
          ..model.signup_ui,
          error: option.Some("An account with this email already exists"),
        )
      #(Model(..model, signup_ui:), effect.none())
    }
    message.UserChangedLoginEmail(email) -> {
      let login_ui =
        model.LoginUi(..model.login_ui, email: email, error: option.None)
      #(Model(..model, login_ui:), effect.none())
    }
    message.UserChangedLoginPassword(password) -> {
      let login_ui =
        model.LoginUi(..model.login_ui, password: password, error: option.None)
      #(Model(..model, login_ui:), effect.none())
    }
    message.UserSubmittedLogin -> {
      let email = echo model.login_ui.email |> string.trim()
      let password = echo model.login_ui.password |> string.trim()
      let fx = api.post_login(message.ApiLoggedInUser, email:, password:)
      #(model, fx)
    }
    message.ApiLoggedInUser(Ok(auth_result)) -> {
      io.println("Login succeeded")
      #(
        Model(
          ..model,
          login_ui: model.initial_login_ui(),
          auth_token: option.Some(auth_result.token),
          current_user: option.Some(auth_result.user),
        ),
        modem.push("/", option.None, option.None),
      )
    }
    message.ApiLoggedInUser(Error(error)) -> {
      let login_ui =
        model.LoginUi(
          ..model.login_ui,
          error: option.Some("Invalid email or password"),
        )
      #(Model(..model, login_ui:), effect.none())
    }
    message.Logout -> {
      #(
        Model(..model, auth_token: option.None, current_user: option.None),
        effect.none(),
      )
    }
    message.None -> #(model, effect.none())
    message.UserClickedCreatePost(community) -> {
      let create_post_ui =
        model.CreatePostUi(
          ..model.create_post_ui,
          community_id: model.community_to_id(community),
        )

      #(Model(..model, create_post_ui:, show_create_post: True), effect.none())
    }
  }
}

fn view(model: Model) {
  html.div(
    [attribute.class("flex flex-col min-h-screen bg-[#222222] text-white")],
    [
      view_header(model),
      case model.route {
        Home -> home.view()
        Signup -> signup.view(model)
        Login -> login.view(model)
        BugReports ->
          html.div([class("flex-1 pt-[50px] flex flex-col mx-auto p-2")], [
            html.div([class("text-2xl my-5 font-bold")], [
              html.text("Bug Reports"),
            ]),
            case model.current_user {
              option.None -> html.text("")
              option.Some(user) ->
                html.div(
                  [
                    event.on_click(message.UserClickedCreatePost(
                      model.BugReport,
                    )),
                    class(
                      "self-end justify-end items-end w-[120px] my-3 bg-[#9253E4] px-3 py-1 rounded text-center cursor-pointer hover:bg-[#A364F5] transition-all ease-in-out duration-300",
                    ),
                  ],
                  [
                    html.text("Create Post"),
                  ],
                )
            },
            html.div([class("flex border-b border-[#555555] pb-2")], [
              html.div([class("md:w-[500px]")], [html.text("Topic")]),
              html.div([class("md:w-[200px]")], [html.text("Author")]),
              html.div([class("md:w-[50px]")], [html.text("Replies")]),
            ]),
            case model.show_create_post {
              True ->
                html.div(
                  [
                    class(
                      "fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-[#222222] p-6 rounded shadow-lg w-[90%] max-w-md text-center z-100",
                    ),
                  ],
                  [html.div([], [html.text("Create Post")])],
                )
              False -> html.text("")
            },
          ])
      },
      html.div(
        [
          class(
            "fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-[#222222] p-6 rounded shadow-lg w-[90%] max-w-md z-100",
          ),
        ],
        [
          html.div([class("text-2xl font-bold mb-3")], [
            html.text("Create Post"),
          ]),
          html.form([class("flex flex-col")], [
            html.div([class("font-bold")], [html.text("Category")]),
            case model.create_post_ui.community_id {
              "bugreport" -> html.div([], [html.text("Bug Report")])
              "general" -> html.div([], [html.text("General Discussion")])
              "techsupport" -> html.div([], [html.text("Technical Support")])
              _ -> html.text("")
            },
            html.input([attribute.placeholder("Title")]),
            html.input([attribute.placeholder("Content")]),
          ]),
        ],
      ),
    ],
  )
}

fn view_header(model: Model) {
  html.header(
    [
      attribute.class(
        "fixed top-0 left-0 w-screen flex justify-between p-2 bg-[#222222]",
      ),
    ],
    [
      html.a(
        [
          event.on_click(message.Navigate("/")),
          attribute.class(
            "pt-1 tracking-[0.25rem] text-xl hover:text-[#9253E4] transition-all ease-in-out duration-300 cursor-pointer",
          ),
        ],
        [
          html.div([class("flex")], [
            html.div([class("mr-2")], [
              html.img([attribute.src("/logo.png"), class("w-[30px]")]),
            ]),
            html.text("ARKHET"),
          ]),
        ],
      ),
      case model.current_user {
        option.None ->
          html.div([class("flex")], [
            html.a(
              [
                event.on_click(message.Navigate("/login")),
                class("px-5 py-2 hover:text-[#9253E4] cursor-pointer"),
              ],
              [html.text("Login")],
            ),
            html.a(
              [
                event.on_click(message.Navigate("/signup")),
                class("bg-[#9253E4] rounded-full px-5 py-2 cursor-pointer"),
              ],
              [html.text("Signup")],
            ),
          ])
        option.Some(user) ->
          html.div([class("flex items-center px-5 py-2")], [
            html.text(echo user.username),
            html.a(
              [
                event.on_click(message.Logout),
                class("ml-4 text-sm hover:text-red-400 cursor-pointer"),
              ],
              [html.text("Logout")],
            ),
          ])
      },
    ],
  )
}

fn on_url_change(uri: uri.Uri) -> message.Msg {
  uri.path
  |> uri.path_segments
  |> model.route_from_path
  |> message.OnRouteChange
}
