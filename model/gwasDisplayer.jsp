<!-- gwasDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder,java.util.List" language="java" %>
<html:xhtml />
<tiles:importAttribute />
<c:set var="width" value="${WEB_PROPERTIES['gwasDisplayer.width']}"/>
<c:set var="height" value="${WEB_PROPERTIES['gwasDisplayer.height']}"/>
<%
// request data from GWASDisplayer
String yuck = (String) request.getAttribute("yuck");
String chromosomeLengths = (String) request.getAttribute("chromosomeLengths");
String vars = (String) request.getAttribute("vars");
String data = (String) request.getAttribute("data");
String traits = (String) request.getAttribute("traits");
%>
<canvas id="canvasx" width="${width}" height="${height}"></canvas>
<br clear="all"/>
<script type="text/javascript">
 var yuck = "<%=yuck%>";
 var webappPath = "/${WEB_PROPERTIES['webapp.path']}/";

 var evts = {
     "click": function(o, e, t) {
         var markerId = o.y.vars[0];
         var markerPrimaryId = yuck+"."+markerId;
         window.open(webappPath+"geneticmarker:"+markerPrimaryId);
     }
 }
 
 var conf = {
     "chromosomeLengths" : <%=chromosomeLengths%>,
     "decorations" : {
         "line" : [
             { "color" : "rgb(0,0,255)", "width" : 1, "y" : 1.3 }
         ]
     },
     "graphType" : "Scatter2D",
     "manhattanMarkerChromosomeNumber" : "Chr",
     "manhattanMarkerLogPValue" : "-log10(p)",
     "manhattanMarkerPosition" : "Pos",
     "scatterType" : "manhattan",
     "title" : "Slide window with mouse; change scale with mouse wheel over axis; select region to zoom in; click marker to see its page.",
     "titleScaleFontFactor": 0.1,
     "disableToolbar": true,
     "colorBy": "Trait",
     "colorByShowLegend": true,
     "canvasBox": true,
     "setMinY": 0.0,
     "dataPointSize": 50,
     "legendBox": false,
     "legendScaleFontFactor": 2,
     "legendInside": false,
     "legendPositionAuto": false,
     "legendPosition": "right",
 }
 
 var data = {
     z : {
         "Trait" : <%=traits%>
     },

     y : {
         "smps": ["Chr","Pos","-log10(p)"],
         "vars": <%=vars%>,
         "data": <%=data%>
     }
 }
 
 var cX = new CanvasXpress("canvasx", data, conf, evts);  
</script>
