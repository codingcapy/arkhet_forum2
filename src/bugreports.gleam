import api
import createpost
import gleam/list
import gleam/option
import lib/async_data
import lib/post_render
import lustre/attribute.{class}
import lustre/element/html
import lustre/event
import message
import model
import rsvp

pub fn view(
  posts: async_data.AsyncData(List(api.Post), rsvp.Error),
  model: model.Model,
) {
  html.div([class("flex-1 pt-[50px] flex flex-col mx-auto p-2")], [
    html.div([class("text-2xl my-5 font-bold")], [
      html.text("Bug Reports"),
    ]),
    case model.current_user {
      option.None -> html.text("")
      option.Some(user) ->
        html.div(
          [
            event.on_click(message.UserClickedCreatePost(model.BugReport)),
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
      True -> createpost.view(model)
      False -> html.text("")
    },
    case posts {
      async_data.NotAsked ->
        html.div([class("text-center")], [html.text("No posts yet")])

      async_data.Loading ->
        html.div([class("text-center")], [html.text("Loading posts…")])

      async_data.Done(Ok(posts)) -> post_render.render_post_list(posts, model)

      async_data.Done(Error(_)) ->
        html.div([class("text-center")], [html.text("Failed to load posts")])
    },
  ])
}

pub fn render_post_list(posts: List(api.Post), model: model.Model) {
  html.div(
    [class("mb-2")],
    posts
      |> list.map(fn(post) { render_post(post, model) }),
  )
}

pub fn render_post(post: api.Post, model: model.Model) {
  html.div([class("flex border-b border-[#555555] py-5")], [
    html.div([class("md:w-[500px]")], [html.text(post.title)]),
    html.div([class("md:w-[200px]")], [html.text(post.user_id)]),
    html.div([class("md:w-[50px]")], [html.text("Loading...")]),
    html.div([], []),
  ])
}
