import api
import bugreports
import general
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleam/uri
import header
import home
import lib/async_data
import login
import lustre
import lustre/attribute
import lustre/effect
import lustre/element/html
import message
import model.{type Model, BugReports, Home, Login, Model, Signup}
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
      posts: async_data.Loading,
    )
  let fx =
    effect.batch([
      modem.init(on_url_change),
      fetch_posts_for_route(model.route),
    ])
  #(model, fx)
}

fn update(
  model: Model,
  msg: message.Msg,
) -> #(Model, effect.Effect(message.Msg)) {
  case echo msg {
    message.OnRouteChange(route) -> {
      case route {
        model.BugReports -> #(
          Model(..model, route: route, posts: async_data.Loading),
          api.get_bugreport_posts(message.ApiReturnedPosts),
        )
        model.TechnicalSupport -> #(
          Model(..model, route: route, posts: async_data.Loading),
          api.get_techsupport_posts(message.ApiReturnedPosts),
        )
        model.GeneralDiscussions -> #(
          Model(..model, route: route, posts: async_data.Loading),
          api.get_general_posts(message.ApiReturnedPosts),
        )
        _ -> #(Model(..model, route: route), effect.none())
      }
    }
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
    message.UserToggledCreatePostDropdown(state) -> {
      let create_post_ui =
        model.CreatePostUi(..model.create_post_ui, show_dropdown: !state)
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
    message.UserChangedPostTitle(title) -> {
      let create_post_ui =
        model.CreatePostUi(..model.create_post_ui, title: title)
      #(Model(..model, create_post_ui:), effect.none())
    }
    message.UserChangedPostContent(content) -> {
      let create_post_ui =
        model.CreatePostUi(..model.create_post_ui, content: content)
      #(Model(..model, create_post_ui:), effect.none())
    }
    message.UserSubmittedCreatePost -> {
      let title = echo model.create_post_ui.title |> string.trim()
      let content = echo model.create_post_ui.content |> string.trim()
      let community_id = echo model.create_post_ui.community_id |> string.trim()
      case title == "" {
        True -> #(model, effect.none())
        False -> {
          case model.current_user {
            option.Some(user) -> {
              let fx =
                api.post_create_post(
                  message.ApiCreatedPost,
                  user_id: user.user_id,
                  title:,
                  content:,
                  community_id:,
                )
              #(model, fx)
            }
            option.None -> #(model, effect.none())
          }
        }
      }
    }
    message.ApiCreatedPost(Ok(_)) -> {
      #(
        Model(
          ..model,
          create_post_ui: model.initial_create_post_ui(),
          show_create_post: False,
          posts: async_data.Loading,
        ),
        case model.route {
          model.BugReports -> api.get_bugreport_posts(message.ApiReturnedPosts)
          model.TechnicalSupport ->
            api.get_techsupport_posts(message.ApiReturnedPosts)
          model.GeneralDiscussions ->
            api.get_general_posts(message.ApiReturnedPosts)
          _ -> effect.none()
        },
      )
    }
    message.ApiCreatedPost(Error(error)) -> {
      echo error
      let posts = {
        use posts <- async_data.map(model.posts)
        posts
        |> list.filter(fn(post) { post.post_id != 0 })
      }
      #(Model(..model, posts:), effect.none())
    }
    message.ApiReturnedPosts(result) -> {
      #(Model(..model, posts: async_data.Done(result)), effect.none())
    }
    message.None -> #(model, effect.none())
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
        BugReports -> bugreports.view(model.posts, model)
        model.GeneralDiscussions -> general.view(model.posts, model)
        model.TechnicalSupport -> techsupport.view(model.posts, model)
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

fn fetch_posts_for_route(route: model.Route) -> effect.Effect(message.Msg) {
  case route {
    model.BugReports -> api.get_bugreport_posts(message.ApiReturnedPosts)

    model.TechnicalSupport ->
      api.get_techsupport_posts(message.ApiReturnedPosts)

    model.GeneralDiscussions -> api.get_general_posts(message.ApiReturnedPosts)

    _ -> effect.none()
  }
}
