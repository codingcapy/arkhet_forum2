import lustre/attribute.{class}
import lustre/element/html
import lustre/event
import message
import model

pub fn view(model: model.Model) {
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
                "techsupport" -> html.div([], [html.text("Technical Support")])
                _ -> html.text("")
              },
              html.div([class("pt-1")], [
                html.img([attribute.src("/iconcaretdown.svg")]),
              ]),
            ],
          ),
          html.div([class("absolute top-[50px] left-0")], [html.text("HERE")]),
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
  )
}
