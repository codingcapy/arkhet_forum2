import api
import bugreports
import createpost
import general
import gleam/io
import gleam/option
import gleam/string
import gleam/uri
import header
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
import techsupport

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
    message.UserCancelledCreatePost -> #(
      Model(..model, show_create_post: False),
      effect.none(),
    )
    message.UserToggledCreatePostDropdown -> {
      let create_post_ui =
        model.CreatePostUi(..model.create_post_ui, show_dropdown: True)
      #(Model(..model, create_post_ui:), effect.none())
    }
    message.UserSelectedCommunity(community) -> {
      let create_post_ui =
        model.CreatePostUi(
          ..model.create_post_ui,
          show_dropdown: False,
          community_id: model.community_to_id(community),
        )
      #(Model(..model, create_post_ui:), effect.none())
    }
  }
}

fn view(model: Model) {
  html.div(
    [attribute.class("flex flex-col min-h-screen bg-[#222222] text-white")],
    [
      header.view(model),
      case model.route {
        Home -> home.view()
        Signup -> signup.view(model)
        Login -> login.view(model)
        BugReports -> bugreports.view(model)
        model.GeneralDiscussions -> general.view(model)
        model.TechnicalSupport -> techsupport.view(model)
      },
      html.div(
        [
          class(
            "fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-[#333333] p-6 rounded shadow-lg w-[90%] max-w-md z-100",
          ),
        ],
        [
          html.div([class("text-2xl font-bold mb-3")], [
            html.text("Create Post"),
          ]),
          html.form([class("flex flex-col")], [
            html.div([class("font-bold")], [html.text("Category")]),
            html.div([class("relative")], [
              html.div(
                [
                  class(
                    "flex justify-between w-[200px] border px-2 my-2 cursor-pointer hover:bg-[#444444]",
                  ),
                ],
                [
                  case model.create_post_ui.community_id {
                    "bugreport" -> html.div([], [html.text("Bug Report")])
                    "general" -> html.div([], [html.text("General Discussion")])
                    "techsupport" ->
                      html.div([], [html.text("Technical Support")])
                    _ -> html.text("")
                  },
                  html.div([class("pt-1")], [
                    html.img([attribute.src("/iconcaretdown.svg")]),
                  ]),
                ],
              ),
              html.div(
                [class("absolute top-[50px] left-0 bg-[#333333] w-[200px]")],
                [
                  html.div([], [
                    html.text("HERE"),
                  ]),
                  html.div([], [
                    html.text("HERE"),
                  ]),
                  html.div([], [
                    html.text("HERE"),
                  ]),
                ],
              ),
            ]),
            html.input([
              attribute.placeholder("Title"),
              attribute.required(True),
              class("border px-2 py-1 my-2"),
            ]),
            html.textarea(
              [
                attribute.placeholder("Content"),
                attribute.required(True),
                class("border px-2 py-1 my-1 h-[100px]"),
              ],
              "",
            ),
            html.button(
              [
                class(
                  "my-2 px-3 py-1 bg-[#9253E4] cursor-pointer hover:bg-[#A364F5]",
                ),
              ],
              [
                html.text("CREATE"),
              ],
            ),
            html.div(
              [
                event.on_click(message.UserCancelledCreatePost),
                class(
                  "my-2 px-3 py-1 bg-[#444444] cursor-pointer hover:bg-[#555555] text-center",
                ),
              ],
              [
                html.text("Cancel"),
              ],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn on_url_change(uri: uri.Uri) -> message.Msg {
  uri.path
  |> uri.path_segments
  |> model.route_from_path
  |> message.OnRouteChange
}
