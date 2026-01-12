#import "../../lib.typ" as loom
#import "lw-layout.typ"
#import "lw-content.typ"
#import "components/primitives.typ": separator

#let portal(target, body) = lw-layout.data-motif(
  "portal",
  measure: (..) => (target: target, body: body),
)

#let connect(body) = lw-layout.motif(
  measure: (_, child-data) => {
    let portal-collection = (:)

    for portal in loom.query.collect-signals(child-data, kind: "portal") {
      portal-collection.insert(
        portal.target,
        portal-collection.at(portal.target, default: ()) + (portal.body,),
      )
    }

    (
      none,
      portal-collection
        .pairs()
        .map(((key, value)) => (key, value.join(parbreak())))
        .to-dict(),
    )
  },
  draw: (_, _, view, body) => {
    lw-content.apply(
      location: "header",
      grid(
        columns: (auto, 1fr, 50%),
        gutter: 1em,
        align: horizon,

        view.at("header-title", default: []),
        [],
        view.at("header-box", default: []),
      ),
    )

    v(0.5em)
    separator()

    let has-sidebar = "sidebar" in view

    grid(
      columns: if has-sidebar { (5cm, 1fr) } else { 1fr },
      gutter: 1em,
      ..if has-sidebar {
        (
          lw-content.apply(
            location: "sidebar",
            block(width: 100%, height: 1fr, view.at("sidebar", default: [])),
          ),
        )
      },
      {
        lw-content.apply(location: "body", {
          set par(justify: true)
          body
        })
        v(1fr)
        lw-content.apply(location: "bottom", {
          view.at("bottom", default: [])
        })
      },
    )
  },
  body,
)

#let paper-base = rgb("#f4e8d4")
#let paper-edge = rgb("#e6d3b3")

#let layout-sheet(body) = {
  set page(
    paper: "a4",
    margin: (x: 1cm, y: 1cm),
    background: {
      place(image(width: 100%, height: 100%, fit: "cover", "paper-texture.jpg"))
      place(rect(width: 100%, height: 100%, fill: gradient.radial(
        (paper-base.transparentize(20%), 0%),
        (paper-base.transparentize(10%), 60%),
        (paper-edge.transparentize(2%), 100%),
        center: (50%, 50%),
        radius: 80%,
      )))
    },
  )

  set text(font: "Linux Libertine", size: 10pt, fill: rgb("#2a2a2a"))

  let post-portal = lw-layout.weave(
    max-passes: 1,
    connect(body),
  )

  post-portal
}

#let sidebar = portal.with("sidebar")
#let bottom = portal.with("bottom")
