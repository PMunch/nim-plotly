import tables
import json
import chroma

# plotly internal modules
import plotly_types
import color
import errorbar

func `%`*(c: Color): string =
  result = c.toHtmlHex()

func `%`*(f: Font): JsonNode =
  var fields = initOrderedTable[string, JsonNode](4)
  if f.size != 0:
    fields["size"] = % f.size
  if f.color.empty:
    fields["color"] = % f.color.toHtmlHex()
  if f.family != nil and f.family != "":
    fields["family"] = % f.family
  result = JsonNode(kind:Jobject, fields:  fields)

func `%`*(a: Axis): JsonNode =
  var fields = initOrderedTable[string, JsonNode](4)
  if a.title != nil and a.title != "":
    fields["title"] = % a.title
  if a.font != nil:
    fields["titlefont"] = % a.font
  if a.domain != nil:
    fields["domain"] = % a.domain
  if a.side != PlotSide.Unset:
    fields["side"] = % a.side
    fields["overlaying"] = % "y"

  result = JsonNode(kind:Jobject, fields:  fields)

func `%`*(l: Layout): JsonNode =
  var fields = initOrderedTable[string, JsonNode](4)
  if l.title != "":
    fields["title"] = % l.title
  if l.width != 0:
    fields["width"] = % l.width
  if l.height != 0:
    fields["height"] = % l.height
  if l.xaxis != nil:
    fields["xaxis"] = % l.xaxis
  if l.yaxis != nil:
    fields["yaxis"] = % l.yaxis
  if l.yaxis2 != nil:
    fields["yaxis2"] = % l.yaxis2
  if $l.barmode != "":
    fields["barmode"] = % l.barmode

  result = JsonNode(kind:Jobject, fields:  fields)

func `%`*(b: ErrorBar): JsonNode =
  ## creates a JsonNode from an `ErrorBar` object depending on the object variant
  var fields = initOrderedTable[string, JsonNode](4)
  fields["visible"] = % b.visible
  fields["color"] = % b.color.toHtmlHex
  if b.thickness > 0:
    fields["thickness"] = % b.thickness
  if b.width > 0:
    fields["width"] = % b.width
  case b.kind
  of ebkConstantSym:
    fields["symmetric"] = % true
    fields["type"] = % "constant"
    fields["value"] = % b.value
  of ebkConstantAsym:
    fields["symmetric"] = % false
    fields["type"] = % "constant"
    fields["valueminus"] = % b.valueMinus
    fields["value"] = % b.valuePlus
  of ebkPercentSym:
    fields["symmetric"] = % true
    fields["type"] = % "percent"
    fields["value"] = % b.percent
  of ebkPercentAsym:
    fields["symmetric"] = % false
    fields["type"] = % "percent"
    fields["valueminus"] = % b.percentMinus
    fields["value"] = % b.percentPlus
  of ebkSqrt:
    fields["type"] = % "sqrt"
  of ebkArraySym:
    fields["symmetric"] = % true
    fields["type"] = % "data"
    fields["array"] = % b.errors
  of ebkArrayAsym:
    fields["symmetric"] = % false
    fields["type"] = % "data"
    fields["arrayminus"] = % b.errorsMinus
    fields["array"] = % b.errorsPlus
  result = JsonNode(kind: JObject, fields: fields)

func `%`*(t: Trace): JsonNode =
  var fields = initOrderedTable[string, JsonNode](8)
  if t.xs == nil or t.xs.len == 0:
    if t.text != nil and t.`type` != PlotType.Histogram:
      fields["x"] = % t.text
  else:
    fields["x"] = % t.xs
  if t.yaxis != "":
    fields["yaxis"] = % t.yaxis

  if t.opacity != 0:
    fields["opacity"] = % t.opacity

  if t.ys != nil:
    fields["y"] = % t.ys

  if t.xs_err != nil:
    fields["error_x"] = % t.xs_err
  if t.ys_err != nil:
    fields["error_y"] = % t.ys_err

  fields["mode"] = % t.mode
  fields["type"] = % t.`type`
  if t.name != nil:
    fields["name"] = % t.name
  if t.text != nil:
    fields["text"] = % t.text
  if t.marker != nil:
    fields["marker"] = % t.marker
  result = JsonNode(kind:Jobject, fields: fields)

func `%`*(m: Marker): JsonNode =
  var fields = initOrderedTable[string, JsonNode](8)
  if m.size != nil:
    if m.size.len == 1:
      fields["size"] = % m.size[0]
    else:
      fields["size"] = % m.size
  if m.color != nil:
    if m.color.len == 1:
      fields["color"] = % m.color[0].toHtmlHex()
    else:
      fields["color"] = % m.color.toHtmlHex()
  result = JsonNode(kind:Jobject, fields:  fields)

func `$`*(d: Trace): string =
  var j = % d
  result = $j

func json*(d: Trace, as_pretty=true): string =
  var j = % d
  if as_pretty:
    result = pretty(j)
  else:
    result = $d