import gleam/option
import lustre/attribute.{class}
import lustre/element/html
import lustre/event
import message
import model

pub fn view(model: model.Model) {
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
