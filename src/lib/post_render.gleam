import api
import gleam/list
import lustre/attribute.{class}
import lustre/element/html
import model

pub fn render_post_list(posts: List(api.Post), model: model.Model) {
  html.div(
    [class("mb-2")],
    posts
      |> list.map(fn(post) { render_post(post, model) }),
  )
}

pub fn render_post(post: api.Post, model: model.Model) {
  html.div([class("flex border-b border-[#555555] py-5")], [
    html.div([class("md:w-[500px]")], [
      html.text(post.title),
    ]),
    html.div([class("md:w-[200px]")], [html.text(post.user_id)]),
    html.div([class("md:w-[50px]")], [html.text("Loading...")]),
    html.div([], []),
  ])
}
