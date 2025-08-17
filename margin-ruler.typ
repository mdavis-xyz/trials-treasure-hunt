#import "@preview/cetz:0.4.1": canvas, draw

#let ruler(width, height) = {

  canvas({
    import draw: *

    hide(
      rect((0,0), (width,height), name: "rect")
    )

    // set-style(content: (frame: "rect", stroke: none, fill: white, padding: .1))

    let num-ticks = calc.floor((height + width + height + width) / 1cm)

    
    for i in range(num-ticks+1) {
      
      let tick-len = if calc.rem-euclid(i, 10) == 0 {
        1cm
      } else if calc.rem-euclid(i, 5) == 0 {
        0.75cm
      } else {
        0.5cm
      }

      let text-val = if (calc.rem-euclid(i, 10) == 0) {
        str(i) + " cm"
      } else if (calc.rem-euclid(i, 5) == 0) {
        str(i)
      } else {
        ""
      }
      
      let tick-rel = if i < height.cm() {
        // left
        (tick-len, 0)
      } else if i < (height + width).cm() {
        // bottom
        (0, tick-len)
      } else if i < (height + width + height).cm() {
        // right
        (-tick-len, 0)
      } else {
        // top
        (0, -tick-len)
      }

      let tick-anchor = if i < height.cm() {
        // left
        "north-east"
      } else if i < (height + width).cm() {
        // bottom
        "north-east"
      } else if i < (height + width + height).cm() {
        // right
        "south-west"
      } else {
        // top
        "south-west"
      }

      line((name: "rect", anchor: i *1cm), (rel: tick-rel), stroke: 0.8pt + black)
      
      // are we near a corner?
      let lengths = (0cm, height, width, height, width)
      let near = lengths.enumerate().any(((j, _)) => {
        calc.abs(i - lengths.slice(0, j + 1).sum().cm()) < 1
      })
      
      // // Numbers every 5th centimeter
      if not near {
        content((rel: tick-rel, to: (name: "rect", anchor: i *1cm)), text(size: 8pt, text-val), anchor: tick-anchor, padding: 4pt)
      }
    }

  })

}
