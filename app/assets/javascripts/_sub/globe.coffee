$ ->
  width = $(window).width() 
  height = $(window).height()
  projection = d3.geo.orthographic().translate([width/2, height/2]).scale($(window).width()*0.7).clipAngle(90)

  canvas = d3.select("body").append("canvas").attr("width", width).attr("height", height)
  c = canvas.node().getContext("2d")

  path = d3.geo.path()
    .projection(projection)
    .context(c)

  title = d3.select("h1")

  ready = (error, world, names) ->
    console.log 1
    globe = {type: "Sphere"}
    land = topojson.feature(world, world.objects.land)
    countries = topojson.feature(world, world.objects.countries).features
    compare = (a, b) ->
      a != b
    borders = topojson.mesh(world, world.objects.countries, compare)
    i = -1
    n = countries.length

    countries = countries.filter (d) ->
      return names.some (n) ->
        if +d.id is +n.id
          return d.name = n.name
    .sort (a, b) ->
     return a.name.localeCompare(b.name)

    transition = ->
      d3.transition()
        .duration(1250)
        .each "start", ->
          title.text(countries[i = (i + 1) % n].name)
        .tween "rotate", ->
          p = d3.geo.centroid(countries[i])
          r = d3.interpolate(projection.rotate(), [-p[0], -p[1]])
          return (t) ->
            projection.rotate(r(t))
            c.clearRect(0, 0, width, height)
            c.fillStyle = "#bbb"
            c.beginPath()
            path(land)
            c.fill()

            c.fillStyle = "#f00"
            c.beginPath()
            path(countries[i])
            c.fill()

            c.strokeStyle = "#fff"
            c.lineWidth = .5
            c.beginPath()
            path(borders)
            c.stroke()

            c.strokeStyle = "#000"
            c.lineWidth = 2
            c.beginPath()
            path(globe)
            c.stroke()

      .transition().each("end", transition)

    transition()

  queue()
    .defer(d3.json, "/d/world-110m.json")
    .defer(d3.tsv, "/d/world-country-names.tsv")
    .await(ready)
