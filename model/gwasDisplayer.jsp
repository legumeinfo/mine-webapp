<!-- gwasDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.List" language="java" %>
<html:xhtml />
<tiles:importAttribute />
<c:set var="width" value="${WEB_PROPERTIES['gwasDisplayer.width']}"/>
<c:set var="height" value="${WEB_PROPERTIES['gwasDisplayer.height']}"/>
<%
// get JSON from GWASDisplayer.java
String genomesJSON = (String) request.getAttribute("genomesJSON");
%>
<script type="text/javascript">
 var genomesMap = <%=genomesJSON%>;
 var genomes = Object.keys(genomesMap);

 // populate selector
 var selector = document.getElementById('genome-selector');
 var option;
 for (var i=0; i<genomes.length; i++) {
     option = document.createElement('option');
     option.text = genomes[i];
     option.value = genomes[i];
     selector.add(option);
 }

 // static conf
 var conf = {
     "decorations": {
         "line": [
             { "color": "rgb(0,0,255)", "width": 1, "y": 1.3 }
         ]
     },
     "graphType": "Scatter2D",
     "manhattanMarkerChromosomeNumber": "Chr",
     "manhattanMarkerLogPValue": "-log10(p)",
     "manhattanMarkerPosition": "Pos",
     "scatterType": "manhattan",
     "title": "Slide window with mouse; change scale with mouse wheel over axis; select region to zoom in; click marker to see its page.",
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

 // generate the plot for the selected genome (first being the default)
 function setGenome() {
     var genome = document.getElementById('genome-selector').value;
     var genomeData = genomesMap[genome];
     var evts = {
         "click": function(o, e, t) {
             var markerName = o.y.vars[0];
             var markerIdentifier = genome+"."+markerName;
             window.open("/"+"${WEB_PROPERTIES['webapp.path']}"+"/geneticmarker:"+markerIdentifier);
         }
     }
     // update conf.chromosomeLengths
     conf["chromosomeLengths"] = genomeData["chromosomeLengths"];
     // set the plot data
     var data = {
         z: {
             "Trait": genomeData["traits"]
         },
         y: {
             "smps": ["Chr","Pos","-log10(p)"],
             "vars": genomeData["vars"],
             "data": genomeData["data"]
         }
     }
     // create/update the CanvasXpress object
     var cx = CanvasXpress.$('canvasx');
     if (cx==null) {
         cx = new CanvasXpress('canvasx', data, conf, evts);
     } else {
         cx.updateData(data);
     }
 }

 // create the plot for the default genome
 setGenome();
</script>
<div style="padding:5px 0">
    <select id="genome-selector" onChange="setGenome();"></select> <b>Select a genome for the Manhattan plot</b>
</div>
<canvas id="canvasx" width="${width}" height="${height}"></canvas>
<br clear="all"/>
<!-- /gwasDisplayer.jsp -->
