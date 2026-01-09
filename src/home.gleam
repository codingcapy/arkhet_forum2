import lustre/attribute.{class}
import lustre/element/html

pub fn view() {
  html.div([attribute.class("pt-[150px] max-w-[1000px] mx-auto")], [
    html.div([attribute.class("text-2xl font-bold mb-5")], [
      html.text("Categories"),
    ]),
    html.a([attribute.href("/bugreports")], [
      html.div(
        [
          class(
            "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
          ),
        ],
        [
          html.div([class("text-xl font-bold")], [
            html.text("Bug Reports"),
          ]),
          html.div([class("text-[#bbbbbb]")], [
            html.text("Find a bug? Help us squash it by reporting it here!"),
          ]),
        ],
      ),
    ]),
    html.a([attribute.href("/technicalsupport")], [
      html.div(
        [
          class(
            "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
          ),
        ],
        [
          html.div([class("text-xl font-bold")], [
            html.text("Technical Support"),
          ]),
          html.div([class("text-[#bbbbbb]")], [
            html.text(
              "For account issues such as signing up/logging in, billing and payments",
            ),
          ]),
        ],
      ),
    ]),
    html.a([attribute.href("/generaldiscussions")], [
      html.div(
        [
          class(
            "p-5 my-3 lg:w-[700px] bg-[#303030] border cursor-pointer hover:bg-[#444444]",
          ),
        ],
        [
          html.div([class("text-xl font-bold")], [
            html.text("General Discussion"),
          ]),
          html.div([class("text-[#bbbbbb]")], [
            html.text("Discussion about Arkhet"),
          ]),
        ],
      ),
    ]),
  ])
}
