import createpost
import gleam/option
import lustre/attribute.{class}
import lustre/element/html
import lustre/event
import message
import model

pub fn view(model: model.Model) {
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
  ])
}
