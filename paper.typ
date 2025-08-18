#import "@preview/cades:0.3.0": qr-code
#import "margin-ruler.typ": ruler


#let a4-width = 21cm
#let a4-height = 29.7cm
#let left-margin = 1.5cm
#let right-margin = left-margin
#let top-margin = 1.5cm
#let bottom-margin = top-margin

#set page(
  margin: (left: left-margin, top: top-margin, right: right-margin, bottom: bottom-margin),
  header: place(
    top + left,
    dx: - left-margin - 1pt,
    dy: 0cm,
    ruler(a4-width, a4-height)
  ),
  columns: 2
)

#set text(font: "PT Sans")

#let lang = "fr"
#set text(lang: lang)

#let empty-line(c) = {
  "_" * c
}

#place(
  top + center,
  scope: "parent",
  float: true,
  grid(
    columns: (4fr, 1fr),
    [
      #align(center, text(30pt)[Chasse au Trésor du Trials])
      #v(-30pt)
      Feuille de score pour épreuves de monocycle.
      Pour certaines épreuves, si tu ne  l'as jamais réussi avant, ou jamais d'aussi loin, les points sont doublés.
      Si tu prends la main de quelqu'un, tu obtiens la moitié des points.

      #align(left)[
        #pad(top: 1em,
          [
            Prénom: #empty-line(50)
            Total: #empty-line(15) points
          ]
        )
      ]

    ],
    figure(
      qr-code("https://mdavis-xyz.github.io/trials-treasure-hunt/", width: 2.5cm), 
      caption: [#text(8pt)[Clarifications des épreuves \ et version en ligne]], supplement: none)
  )
)

// remove random spacing
#v(-1em)

/// Create a checkbox
///
/// ```example
/// #checkbox()
/// #checkbox(tick: true)
/// #checkbox(fill: red)
/// #checkbox(fill: green, tick: true)
/// ```
///
/// -> content
#let checkbox(
  /// background color of the box
  /// -> color
  fill: none,
  /// if true a checkmark symbol is shown inside the box.
  /// -> bool
  tick: false
) = box(
  width: 0.8em,
  height: 0.8em,
  stroke: 0.7pt,
  radius: 25%,
  fill: fill,
  if (tick) { align(horizon + center, sym.checkmark) }
)


#let all_tasks = yaml("tasks.yaml")

#let strip_links(text) = {
  text.replace(regex("</?a[^>]*>"), "")
}

// watch out for byte vs grapheme cluster
// e.g. épreauve
#let capitalise-first-letter(s) = {
  if s.len() == 0 {
    return s
  } else if s.first().len() == s.len() {
    return upper(s)
  } else {
    return upper(s.first()) + s.slice(s.first().len())
  } 
}

#assert(capitalise-first-letter("a") == "A")
#assert(capitalise-first-letter("ab") == "Ab")
#assert(capitalise-first-letter("aB") == "AB")
#assert(capitalise-first-letter("") == "")
#assert(capitalise-first-letter("É") == "É")
#assert(capitalise-first-letter("é") == "É")
#assert(capitalise-first-letter("Ép") == "Ép")
#assert(capitalise-first-letter("ép") == "Ép")

#v(1em)

#text(luma(100))[
#text(12pt)[#checkbox(tick: true) *Exemple*]
#align(right)[
  3 pt 
  #set text(8pt)
  #h(0.2em)
   ( #h(2pt) #checkbox(tick: true) $times$ 2 si 1ere  )
  #h(0.2em) 
   (#h(2pt) #checkbox(tick: false) $div$ 2 si tenir)
  #set text(12pt)
  \= #underline("  " + str(6) + "  ") pts
]
]

#for category in all_tasks {
  if category.at("example", default: false) {
    set text(blue)
  } else {
    set text(black)
    grid(
      columns: (1fr, 10em),
      text(15pt)[*#capitalise-first-letter(category.name.at(lang))*],
      align(right)[Sous-total: #empty-line(7) pts]
    )
  }
  for task in category.tasks {
    let text-content = [
      #text(11pt)[#checkbox(tick: category.at("example", default: false)) *#capitalise-first-letter(task.name.at(lang))*]
      #if ("explanation" in task) and (lang in task.explanation) {
        assert(lang in task.explanation, message: "No " + lang + " explanation for " + json.encode(task.explanation))
        text(7pt)[#strip_links(task.explanation.at(lang))]
      }
      // #if "text" in task.at("details", default: (:)) {
      //   text(7pt)[#strip_links(task.details.text)]
      // }
    ]
    block(breakable: false)[
    #if ("unit" in task) or task.at("standard_multipliers", default: false) {
      grid(
        columns: (1pt, 1fr),
        [],
        [
          #text-content
          #align(right)[
            #pad(top: -0.5em)[
                
              #set text(10pt)
              #str(task.points)#text(8pt)[pts]
              #set text(8pt)
              #if "unit" in task {
                [\/ #task.unit.at(lang) $times$ #empty-line(10) ]
              }
              #if task.at("standard_multipliers", default: false) {
                [
                  #h(0.2em)
                  ( #h(2pt) #checkbox() $times$ 2 si 1ere  )
                  #h(0.2em) 
                  (#h(2pt) #checkbox() $div$ 2 si tenir)
                ]
              }
              #set text(10pt)
              \= #empty-line(10) #text(8pt)[pts]

            ]
          ]
        ]
      )



    } else {
      grid(
        columns: (1fr, 3em),
        text-content,
        align(right)[
          #str(task.points)
          #text(8pt)[pts]
        ]
      )
    }]
  }
}
